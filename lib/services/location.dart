import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/location_denied_screen.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  late Position? position;
  late bool dataLoaded;

  @override
  void initState() {
    super.initState();
    dataLoaded = false;
    getCurentLocation();
  }

  Future<dynamic> getCurentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always ||
          permission != LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission();
      }
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      position = currentPosition;
      setState(() => dataLoaded = true);
    } catch (error) {
      setState(() => dataLoaded = true);
      return LocationDeniedScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    } else {
      if (position == null) {
        return LocationDeniedScreen();
      } else {
        return const LoginScreen();
      }
    }
  }
}