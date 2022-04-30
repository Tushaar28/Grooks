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
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'mixpanel.dart';

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
  late bool? _isActive, _isFirstLogin;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isActive = null;
    _isFirstLogin = true;
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

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
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

  Future<void> getUserDetails() async {
    _user = await _repository.getUserDetails();
    return;
  }

  @override
  Widget build(BuildContext context) {
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
                            _mixpanel.identify(_user!.id);
                            if (_isFirstLogin!) {
                              _mixpanel.track('login', properties: {
                                'userId': _user!.id,
                              });
                              _repository.updateUser(userId: _user!.id, data: {
                                'lastLoginAt': DateTime.now(),
                              });
                              _isFirstLogin = false;
                            }
                            _mixpanel.getPeople().set("name", _user!.name);
                            _mixpanel
                                .getPeople()
                                .set("lastLoginAt", DateTime.now());
                            _mixpanel
                                .getPeople()
                                .set("mobile", _user!.mobile!.substring(3));
                            _mixpanel.getPeople().set("referrals", 0);
                            _mixpanel.getPeople().set("app_share_success", 0);
                            _mixpanel.getPeople().increment("total_trades", 0);
                            _mixpanel
                                .getPeople()
                                .increment("total_trades_failed", 0);
                            _mixpanel.getPeople().increment("new_trades", 0);
                            _mixpanel
                                .getPeople()
                                .increment("new_trades_failed", 0);
                            _mixpanel.getPeople().increment("paired_trades", 0);
                            _mixpanel
                                .getPeople()
                                .increment("paired_trades_failed", 0);
                            _mixpanel
                                .getPeople()
                                .increment("cancelled_trades", 0);
                            _mixpanel
                                .getPeople()
                                .increment("cancelled_trades_failed", 0);
                            _mixpanel.getPeople().increment("purchases", 0);
                            _mixpanel
                                .getPeople()
                                .increment("purchases_failed", 0);
                            _mixpanel.getPeople().increment("payouts", 0);
                            _mixpanel
                                .getPeople()
                                .increment("payouts_failed", 0);
                            _mixpanel.getPeople().set("referrals", 0);
                            _mixpanel
                                .getPeople()
                                .increment("store_packs_clicked", 0);
                            _mixpanel
                                .getPeople()
                                .increment("49_pack_clicked", 0);
                            _mixpanel
                                .getPeople()
                                .increment("99_pack_clicked", 0);
                            _mixpanel
                                .getPeople()
                                .increment("199_pack_clicked", 0);
                            _mixpanel
                                .getPeople()
                                .increment("499_pack_clicked", 0);
                            _mixpanel.flush();
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
