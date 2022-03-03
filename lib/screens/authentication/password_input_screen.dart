import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class PasswordScreen extends StatefulWidget {
  final String mobile;
  final String? referralCode;
  const PasswordScreen({
    Key? key,
    required this.mobile,
    this.referralCode,
  }) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  late TextEditingController _passwordController;
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseRepository _repository;
  late bool _isLoading;
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _firebaseAuth = FirebaseAuth.instance;
    _repository = FirebaseRepository();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _isLoading = false;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                    child: AutoSizeText(
                      'Enter your password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                    child: OTPTextField(
                      keyboardType: TextInputType.phone,
                      length: 4,
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
                        _passwordController.text = pin.trim();
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
                        // if (_otpResendCount < 3)
                        //   TextButton(
                        //     onPressed: _wait
                        //         ? null
                        //         : () {
                        //             verifyPhone();
                        //             setState(() {
                        //               _otpResendCount++;
                        //               _start = 30;
                        //               _wait = true;
                        //             });
                        //             startTimer();
                        //             ScaffoldMessenger.of(context)
                        //                 .hideCurrentSnackBar();
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               const SnackBar(
                        //                 content: AutoSizeText('OTP sent'),
                        //                 backgroundColor: Colors.green,
                        //               ),
                        //             );
                        //           },
                        //     child: AutoSizeText(
                        //       _wait
                        //           ? 'Resend OTP in $_start seconds'
                        //           : 'Resend OTP',
                        //       style: TextStyle(
                        //           color: _wait ? Colors.grey : Colors.black),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                        )
                      : _passwordController.text.length == 4
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
                                      var result = await FirebaseFunctions
                                          .instance
                                          .httpsCallable("generateCustomToken")
                                          .call({
                                        "mobile": '+91' + widget.mobile,
                                        "password":
                                            _passwordController.text.trim(),
                                      });
                                      print("RESULT = $result");
                                      // setState(() => _isLoading = true);
                                      // UserCredential credential =
                                      //     await onSubmitted(context);

                                      // Users? userDetails =
                                      //     await _repository.getUserDetails();
                                      // if (userDetails != null) {
                                      //   if (userDetails.isActive == false) {
                                      //     setState(() => _isLoading = false);
                                      //     ScaffoldMessenger.of(context)
                                      //         .hideCurrentSnackBar();
                                      //     ScaffoldMessenger.of(context)
                                      //         .showSnackBar(
                                      //             suspendedAccountSnackbar);
                                      //     return;
                                      //   }
                                      // }

                                      // if (credential
                                      //         .additionalUserInfo!.isNewUser ||
                                      //     userDetails == null) {
                                      //   Navigator.pushAndRemoveUntil(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             UserDetailScreen(
                                      //           user: credential.user!,
                                      //           referralCode:
                                      //               widget.referralCode,
                                      //           sharedViewMap:
                                      //               widget.sharedViewMap,
                                      //           question: widget.question,
                                      //         ),
                                      //       ),
                                      //       (Route<dynamic> route) => false);
                                      // } else {
                                      //   Users? userDetails =
                                      //       await _repository.getUserDetails();
                                      //   await _repository.updateUser(
                                      //     userId: userDetails!.id,
                                      //     data: {'lastLoginAt': DateTime.now()},
                                      //   );
                                      //   if (widget.sharedViewMap != null &&
                                      //       widget.question != null) {
                                      //     // Navigator.pushAndRemoveUntil(
                                      //     //     context,
                                      //     //     MaterialPageRoute(
                                      //     //       builder: (context) =>
                                      //     //           QuestionDetailWidget(
                                      //     //         user: userDetails,
                                      //     //         questionId:
                                      //     //             widget.question!.id,
                                      //     //         questionName:
                                      //     //             widget.question!.name,
                                      //     //         sharedViewMap:
                                      //     //             widget.sharedViewMap,
                                      //     //       ),
                                      //     //     ),
                                      //     //     (route) => false);
                                      //   } else {
                                      //     Navigator.pushAndRemoveUntil(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             NavbarScreen(
                                      //           user: userDetails,
                                      //           initialPage: 'Home',
                                      //         ),
                                      //       ),
                                      //       (Route<dynamic> route) => false,
                                      //     );
                                      //   }
                                      // }
                                    } catch (error) {
                                      print("ERROR = $error");
                                      // setState(() => _isLoading = false);
                                      // ScaffoldMessenger.of(context)
                                      //     .hideCurrentSnackBar();
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   const SnackBar(
                                      //     content:
                                      //         AutoSizeText("An error occured"),
                                      //     backgroundColor: Colors.red,
                                      //   ),
                                      // );
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
