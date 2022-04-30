import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/services/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'app_update_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConnectivityResult? _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late final FirebaseRepository _repository;
  late String _currentVersion;
  late String? _link;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _repository = FirebaseRepository();
    _link = "";
    getPackageDetails();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
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
    if (_connectionStatus == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    if (_connectionStatus != null &&
        _connectionStatus == ConnectivityResult.none) {
      SchedulerBinding.instance!.addPostFrameCallback(
        (timeStamp) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => const Scaffold(
              backgroundColor: Colors.white,
              body: AlertDialog(
                title: Center(
                  child: Text(
                    "Error !!",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
                actions: [
                  Center(
                    child: Text(
                      "No internet connection",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          (route) => false,
        ),
      );
    }
    return Scaffold(
      body: FutureBuilder(
        future: checkVersion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Image.asset("assets/images/logo.png"),
              ),
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
