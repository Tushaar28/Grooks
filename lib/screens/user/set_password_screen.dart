import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'navbar_screen.dart';
import 'onboarding_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String name, phoneNumber, uid, referralCode;
  final File? profilePicture;
  final Mixpanel mixpanel;
  const SetPasswordScreen({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.uid,
    required this.referralCode,
    required this.mixpanel,
    this.profilePicture,
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

  Future<void> addUser() async {
    try {
      await _repository.addUser(
        name: widget.name,
        mobile: widget.phoneNumber,
        uid: widget.uid,
        profilePicture: widget.profilePicture,
        referralCode: widget.referralCode,
        password: _passwordController.text.trim(),
      );
    } catch (error) {
      throw error.toString();
    }
  }

  Future<Users?> getUserDetails() async {
    return await _repository.getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25,
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
                      backgroundColor: Colors.transparent,
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
                      backgroundColor: Colors.transparent,
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
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() => _isLoading = true);
                            if (_passwordController.text.trim().length != 4) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: AutoSizeText("Password is required"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              setState(() => _isLoading = false);
                              return;
                            }
                            if (!RegExp(r"^[0-9]{4}$")
                                .hasMatch(_passwordController.text.trim())) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: AutoSizeText(
                                      "Password should contain 4 digits"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              setState(() => _isLoading = false);
                              return;
                            }
                            if (_passwordController.text.trim() !=
                                _confirmPasswordController.text.trim()) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      AutoSizeText("Password do not match"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              setState(() => _isLoading = false);
                              return;
                            }
                            await addUser();
                            Users? user = await getUserDetails();
                            widget.mixpanel.identify(user!.id);
                            widget.mixpanel.track("signup", properties: {
                              "userId": user.id,
                            });
                            widget.mixpanel.track("login", properties: {
                              "userId": user.id,
                            });
                            setState(() => _isLoading = false);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OnboardingScreen(user: user),
                              ),
                              (r) => false,
                            );
                            widget.mixpanel.getPeople().set("name", user.name);
                            widget.mixpanel
                                .getPeople()
                                .set("mobile", user.mobile!.substring(3));
                            widget.mixpanel
                                .getPeople()
                                .set("lastLoginAt", DateTime.now());
                            widget.mixpanel.getPeople().set("referrals", 0);
                            widget.mixpanel
                                .getPeople()
                                .set("app_share_success", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("total_trades", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("total_trades_failed", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("new_trades", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("new_trades_failed", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("paired_trades", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("paired_trades_failed", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("cancelled_trades", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("cancelled_trades_failed", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("purchases", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("purchases_failed", 0);
                            widget.mixpanel.getPeople().increment("payouts", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("payouts_failed", 0);
                            widget.mixpanel.getPeople().set("referrals", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("store_packs_clicked", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("49_pack_clicked", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("99_pack_clicked", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("199_pack_clicked", 0);
                            widget.mixpanel
                                .getPeople()
                                .increment("499_pack_clicked", 0);
                            widget.mixpanel.getPeople().setOnce(
                                "createdAt", DateTime.now().toString());
                            widget.mixpanel.flush();
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
      ),
    );
  }
}
