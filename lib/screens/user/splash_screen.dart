import 'dart:async';
import 'package:grooks_dev/services/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'app_update_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final FirebaseRepository _repository;
  late String _currentVersion;
  late String? _link;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _link = "";
    getPackageDetails();
  }

  Future<void> getPackageDetails() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() => _currentVersion = packageInfo.version);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<String> getVersionDetails() async {
    try {
      String requiredVersion = await _repository.getRequiredVersion;
      return requiredVersion;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> checkVersion() async {
    try {
      String requiredVersion = await getVersionDetails();
      if (requiredVersion != _currentVersion) {
        _link = await _repository.getAppLink;
      }
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkVersion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                Image.asset(
                  "assets/images/splash_bg.png",
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                ),
                Center(
                  child: Image.asset("assets/images/splash_fg.png"),
                ),
              ],
            );
          }
          if (_link != null && _link!.isNotEmpty) {
            return AppUpdateScreen(link: _link!);
          }
          return const Location();
        },
      ),
    );
  }
}
