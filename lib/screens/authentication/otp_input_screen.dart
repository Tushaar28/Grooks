import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/my_encryption.dart';

class OTPInputScreen extends StatefulWidget {
  final String mobile;
  final String? referralCode;
  final Map<String, dynamic>? sharedViewMap;
  final Question? question;
  const OTPInputScreen({
    Key? key,
    required this.mobile,
    this.referralCode,
    this.question,
    this.sharedViewMap,
  }) : super(key: key);

  @override
  _OTPInputScreenState createState() => _OTPInputScreenState();
}

class _OTPInputScreenState extends State<OTPInputScreen> {
  late TextEditingController _otpController;
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseRepository _repository;
  //late final DynamicLinkApi _dynamicLink;
  late final FirebaseMessaging _messaging;
  late bool _isCodeSent;
  late bool _isLoading;
  late String? _verificationId;
  late int _start;
  late bool _wait;
  late Timer? _timer;
  late int _otpResendCount;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  final invalidOTPSnackbar = const SnackBar(
    content: AutoSizeText('Invalid OTP. Please try again.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  final loginFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured. Please try again.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  final suspendedAccountSnackbar = const SnackBar(
    content: AutoSizeText('Your account has been suspended.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    //_dynamicLink = DynamicLinkApi();
    _firebaseAuth = FirebaseAuth.instance;
    _messaging = FirebaseMessaging.instance;
    _repository = FirebaseRepository();
    _isCodeSent = _isLoading = _wait = false;
    _start = 30;
    _otpResendCount = 3;
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> initDeviceToken() async {
    _messaging.subscribeToTopic('test');
    String? token = await _messaging.getToken();
    _repository.saveDeviceToken(token);
  }

  Future<String> generateReferralCode(
      String userName, String userMobile) async {
    var id = MyEncryptionDecryption.encryptAES(userMobile);
    var randomCode = "${userName.substring(0, 3)}-${id.base64.substring(0, 8)}";
    return randomCode;
  }

  Future<void> saveReferralLink(String link) async {
    _repository.savePlayerReferalLink(link);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
