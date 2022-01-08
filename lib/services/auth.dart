import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/maintenance_screen.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/services/dynamic_link.dart';

class Auth extends StatefulWidget {
  final String? referralCode;
  const Auth({
    Key? key,
    this.referralCode,
  }) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  late final FirebaseRepository _repository;
  late final FirebaseMessaging _messaging;
  late final DynamicLinkApi _dynamicLink;
  late Users? _user;
  late Map<String, dynamic>? _maintenanceStatus;
  late bool? _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = null;
    _dynamicLink = DynamicLinkApi();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _messaging = FirebaseMessaging.instance;
    _user = null;
    _maintenanceStatus = null;
    if (widget.referralCode == null) {
      () async {
        await Future.delayed(Duration.zero);
        _dynamicLink.handleDynamicLink(context);
      }();
    }
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus();
    setState(() => _isActive = data);
  }

  Future<bool> getMaintenanceStatus() async {
    try {
      _maintenanceStatus = await _repository.getMaintenanceStatus;
      return _maintenanceStatus!['status'] ?? true;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> initDeviceToken() async {
    _messaging.subscribeToTopic('test');
    String? token = await _messaging.getToken();
    _repository.saveDeviceToken(token);
  }

  Future<void> getUserDetails() async {
    _user = await _repository.getUserDetails();
    return;
  }

  @override
  Widget build(BuildContext context) {
    print("CALLED");
    if (_isActive == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    if (_isActive == false) {
      _repository.signOut();
      SchedulerBinding.instance!.addPostFrameCallback(
        (timeStamp) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      );
    }
    return FutureBuilder(
        future: getMaintenanceStatus(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            );
          } else if (_maintenanceStatus!['status'] == true) {
            return MaintenanceScreen(
                maintenanceMessage: _maintenanceStatus!['message']);
          } else {
            return StreamBuilder(
              initialData: const CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return FutureBuilder(
                      future: getUserDetails(),
                      builder: (BuildContext context, AsyncSnapshot data) {
                        if (data.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),
                          );
                        } else {
                          if (_user != null) {
                            initDeviceToken();
                            _repository.updateUser(userId: _user!.id, data: {
                              'lastLoginAt': DateTime.now(),
                            });
                            FirebaseCrashlytics.instance
                                .setUserIdentifier(_user!.id);
                            return NavbarScreen(user: _user);
                          } else {
                            return LoginScreen(
                              referralCode: widget.referralCode,
                            );
                          }
                        }
                      });
                } else {
                  return LoginScreen(
                    referralCode: widget.referralCode,
                  );
                }
              },
            );
          }
        });
  }
}
