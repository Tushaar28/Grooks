import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/otp_input_screen.dart';
import 'package:grooks_dev/screens/authentication/password_input_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final String? referralCode;
  final Map<String, dynamic>? sharedViewMap;
  final Question? question;
  const LoginScreen({
    Key? key,
    this.referralCode,
    this.sharedViewMap,
    this.question,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _mobileController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late final String _url;

  @override
  void initState() {
    super.initState();
    _url =
        "https://drive.google.com/file/d/1Hk7I-GgBmICcz2ipssuIS4shqtWQuDyG/view?usp=sharing";
    _mobileController = TextEditingController();
    _repository = FirebaseRepository();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<bool> isNewUser() async {
    try {
      return await _repository.isNewUser(
          mobile: "+91" + _mobileController.text.trim());
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEDECEC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              "assets/images/login_bg1.png",
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05,
                0,
                MediaQuery.of(context).size.width * 0.05,
                0,
              ),
              alignment: Alignment.bottomCenter,
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: TextField(
                      controller: _mobileController,
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Enter phone number',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.053,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Pattern pattern = r'^[6789]\d{9}$';
                        RegExp regex = RegExp(pattern.toString());
                        if (!regex.hasMatch(_mobileController.text.trim())) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  AutoSizeText('Enter valid mobile number'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PasswordScreen(
                                mobile: _mobileController.text.trim(),
                                referralCode: widget.referralCode,
                              ),
                            ),
                          );
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => OTPInputScreen(
                          //       mobile: _mobileController.text.trim(),
                          //       referralCode: widget.referralCode,
                          //     ),
                          //   ),
                          // );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "By logging in, you agree to our ",
                        ),
                        TextSpan(
                          text: "Terms and Conditions",
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async => await launch(_url),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
