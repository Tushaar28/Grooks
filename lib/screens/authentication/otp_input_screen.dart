import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';

import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/screens/user/user_detail_screen.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

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
    _otpResendCount = 0;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    verifyPhone();
    startTimer();

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

  void startTimer() {
    const onSec = Duration(seconds: 1);
    _timer = Timer.periodic(onSec, (timer) {
      if (mounted) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _wait = false;
          });
        } else {
          setState(() => _start--);
        }
      }
    });
  }

  Future<void> verifyPhone() async {
    // ignore: prefer_function_declarations_over_variables
    final PhoneVerificationCompleted verified =
        (AuthCredential credential) async {
      UserCredential user = await _repository.signIn(credential);
      Users? userDetails = await _repository.getUserDetails();
      if (user.additionalUserInfo!.isNewUser) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(
                user: user.user!,
                referralCode: widget.referralCode,
                sharedViewMap: widget.sharedViewMap,
                question: widget.question,
              ),
            ),
            (Route<dynamic> route) => false);
      } else {
        if (userDetails == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailScreen(
                  user: user.user!,
                  sharedViewMap: widget.sharedViewMap,
                  question: widget.question,
                ),
              ),
              (route) => false);
        } else if (userDetails.isActive == false) {
          ScaffoldMessenger.maybeOf(context)!.hideCurrentSnackBar();
          ScaffoldMessenger.maybeOf(context)!
              .showSnackBar(suspendedAccountSnackbar);
          setState(() => _isLoading = false);
        } else {
          if (widget.sharedViewMap != null && widget.question != null) {
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => QuestionDetailWidget(
            //         user: userDetails,
            //         questionId: widget.question!.id,
            //         sharedViewMap: widget.sharedViewMap,
            //       ),
            //     ),
            //     (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => NavbarScreen(
                          user: userDetails,
                          initialPage: 'Home',
                        )),
                (Route<dynamic> route) => false);
          }
        }
      }
    };

    // ignore: prefer_function_declarations_over_variables
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException exception) async {};

    // ignore: prefer_function_declarations_over_variables
    final PhoneCodeSent smsSent = (String verId, [int? forceResend]) {
      _verificationId = verId;
      setState(() => _isCodeSent = true);
    };

    // ignore: prefer_function_declarations_over_variables
    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      _verificationId = verId;
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+91${widget.mobile}',
        timeout: const Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  Future<UserCredential> onSubmitted(BuildContext context) async {
    try {
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _otpController.text);
      UserCredential result =
          await _firebaseAuth.signInWithCredential(authCredential);
      if (result.user == null) throw 'Invalid OTP';
      return result;
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AutoSizeText(
                          'We have sent verification code to',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        AutoSizeText(
                          '+91-${widget.mobile}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                    child: OTPTextField(
                      keyboardType: TextInputType.phone,
                      length: 6,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: MediaQuery.of(context).size.width * 0.13,
                      otpFieldStyle: OtpFieldStyle(
                        backgroundColor: Colors.white,
                        borderColor: Colors.black,
                        enabledBorderColor: Colors.black,
                        focusBorderColor: Colors.black,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldStyle: FieldStyle.underline,
                      onCompleted: (String pin) {
                        _otpController.text = pin.trim();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const AutoSizeText(
                            'Change number',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        if (_otpResendCount < 3)
                          TextButton(
                            onPressed: _wait
                                ? null
                                : () {
                                    verifyPhone();
                                    setState(() {
                                      _otpResendCount++;
                                      _start = 30;
                                      _wait = true;
                                    });
                                    startTimer();
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: AutoSizeText('OTP sent'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                            child: AutoSizeText(
                              _wait
                                  ? 'Resend OTP in $_start seconds'
                                  : 'Resend OTP',
                              style: TextStyle(
                                  color: _wait ? Colors.grey : Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                        )
                      : _otpController.text.length == 6
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(
                                0,
                                MediaQuery.of(context).size.height * 0.2,
                                0,
                                0,
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  child: const Text("Validate"),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () async {
                                    try {
                                      setState(() => _isLoading = true);
                                      UserCredential credential =
                                          await onSubmitted(context);
                                      initDeviceToken();

                                      Users? userDetails =
                                          await _repository.getUserDetails();
                                      if (userDetails != null) {
                                        if (userDetails.isActive == false) {
                                          setState(() => _isLoading = false);
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  suspendedAccountSnackbar);
                                          return;
                                        }
                                      }

                                      if (credential
                                              .additionalUserInfo!.isNewUser ||
                                          userDetails == null) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserDetailScreen(
                                                user: credential.user!,
                                                referralCode:
                                                    widget.referralCode,
                                                sharedViewMap:
                                                    widget.sharedViewMap,
                                                question: widget.question,
                                              ),
                                            ),
                                            (Route<dynamic> route) => false);
                                      } else {
                                        Users? userDetails =
                                            await _repository.getUserDetails();
                                        await _repository.updateUser(
                                          userId: userDetails!.id,
                                          data: {'lastLoginAt': DateTime.now()},
                                        );
                                        if (widget.sharedViewMap != null &&
                                            widget.question != null) {
                                          // Navigator.pushAndRemoveUntil(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           QuestionDetailWidget(
                                          //         user: userDetails,
                                          //         questionId:
                                          //             widget.question!.id,
                                          //         questionName:
                                          //             widget.question!.name,
                                          //         sharedViewMap:
                                          //             widget.sharedViewMap,
                                          //       ),
                                          //     ),
                                          //     (route) => false);
                                        } else {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NavbarScreen(
                                                user: userDetails,
                                                initialPage: 'Home',
                                              ),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        }
                                      }
                                    } catch (error) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              AutoSizeText("An error occured"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
