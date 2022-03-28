import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import 'navbar_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String userId;
  const SetPasswordScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _repository = FirebaseRepository();
    _isLoading = false;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> setPassword() async {
    try {
      await _repository.setPassword(
        userId: widget.userId,
        password: _passwordController.text.trim(),
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
              ),
              child: const Center(
                child: AutoSizeText(
                  "Set your 4 digit password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: OTPTextField(
                  keyboardType: TextInputType.phone,
                  obscureText: true,
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
                  onChanged: (String value) {
                    _passwordController.text = value;
                  },
                  onCompleted: (String pin) {
                    _passwordController.text = pin.trim();
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.08,
              ),
              child: const Center(
                child: AutoSizeText(
                  "Confirm your 4 digit password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: OTPTextField(
                  keyboardType: TextInputType.phone,
                  obscureText: true,
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
                  onChanged: (String value) {
                    _confirmPasswordController.text = value;
                  },
                  onCompleted: (String pin) {
                    _confirmPasswordController.text = pin.trim();
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.09,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.8,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : CustomButton(
                      onPressed: () async {
                        try {
                          if (_passwordController.text.trim().length != 4) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: AutoSizeText("Password is required"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          if (!RegExp(r"^[0-9]{4}$")
                              .hasMatch(_passwordController.text.trim())) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: AutoSizeText(
                                    "Password should contain 4 digits"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          if (_passwordController.text.trim() !=
                              _confirmPasswordController.text.trim()) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: AutoSizeText("Password do not match"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          setState(() => _isLoading = true);
                          await setPassword();
                          setState(() => _isLoading = false);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavbarScreen(),
                            ),
                            (r) => false,
                          );
                        } catch (error) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: AutoSizeText('An error occured'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      text: "Continue",
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
