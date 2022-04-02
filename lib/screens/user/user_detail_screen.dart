import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/services/my_encryption.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import 'onboarding_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  final String? referralCode;
  final Map<String, dynamic>? sharedViewMap;
  final Question? question;
  const UserDetailScreen({
    Key? key,
    required this.user,
    this.referralCode,
    this.sharedViewMap,
    this.question,
  }) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _referralController;
  late final ImagePicker _picker;
  late File? _profilePicture;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final GlobalKey<FormState> _formKey;
  late final FirebaseRepository _repository;
  late bool _isLoading;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _referralController = TextEditingController();
    _referralController.text = widget.referralCode ?? "";
    _picker = ImagePicker();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formKey = GlobalKey<FormState>();
    _repository = FirebaseRepository();
    _isLoading = false;
    _profilePicture = null;
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> addUser() async {
    try {
      String name = _lastNameController.text.isNotEmpty
          ? _firstNameController.text.trim() + ' ' + _lastNameController.text
          : _firstNameController.text.trim();

      await _repository.addUser(
        name: name,
        mobile: widget.user.phoneNumber,
        uid: widget.user.uid,
        profilePicture: _profilePicture,
        referralCode: _referralController.text.trim(),
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
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: const AutoSizeText(
                      'Your information',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePicture == null
                              ? null
                              : FileImage(_profilePicture!),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            color: Colors.blue,
                            onPressed: () async {
                              try {
                                final pickedFile = await _picker.getImage(
                                  source: ImageSource.gallery,
                                  maxHeight: 256,
                                  maxWidth: 256,
                                );
                                setState(() {
                                  _profilePicture = File(pickedFile!.path);
                                });
                              } catch (error) {}
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.028,
                        0,
                        0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _firstNameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your first name',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                        validator: (String? value) {
                          return value!.isEmpty
                              ? 'First name is required'
                              : null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.028,
                        0,
                        0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _lastNameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter your last name',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.028,
                        0,
                        0,
                      ),
                      child: TextFormField(
                        readOnly: true,
                        initialValue: widget.user.phoneNumber,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.028,
                        0,
                        0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _referralController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Referral Code',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Enter referral code',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 20,
                    ),
                    child: Center(
                      child: AutoSizeText(
                        "Set your 4 digit passcode",
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
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 20,
                    ),
                    child: Center(
                      child: AutoSizeText(
                        "Confirm your 4 digit passcode",
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
                    height: MediaQuery.of(context).size.height * 0.03,
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
                                setState(() => _isLoading = true);
                                if (_passwordController.text.trim().length !=
                                    4) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          AutoSizeText("Password is required"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  setState(() => _isLoading = false);
                                  return;
                                }
                                if (!RegExp(r"^[0-9]{4}$").hasMatch(
                                    _passwordController.text.trim())) {
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
                                if (_formKey.currentState!.validate()) {
                                  await addUser();
                                  Users? user = await getUserDetails();
                                  _mixpanel.identify(user!.id);
                                  _mixpanel.track("signup", properties: {
                                    "userId": user.id,
                                  });
                                  _mixpanel.track("login", properties: {
                                    "userId": user.id,
                                  });
                                  if (widget.sharedViewMap != null &&
                                      widget.question != null) {
                                    setState(() => _isLoading = false);
                                    // Navigator.pushAndRemoveUntil(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           QuestionDetailScreen(
                                    //         user: user,
                                    //         questionId: widget.question!.id,
                                    //         questionName:
                                    //             widget.question!.name,
                                    //         sharedViewMap:
                                    //             widget.sharedViewMap,
                                    //       ),
                                    //     ),
                                    //     (route) => false);
                                  } else {
                                    setState(() => _isLoading = false);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OnboardingScreen(user: user),
                                      ),
                                      (r) => false,
                                    );
                                  }
                                  _mixpanel.getPeople().set("name", user.name);
                                  _mixpanel
                                      .getPeople()
                                      .set("mobile", user.mobile!.substring(2));
                                  _mixpanel.getPeople().set("referrals", 0);
                                  _mixpanel
                                      .getPeople()
                                      .set("app_share_success", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("total_trades", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("total_trades_failed", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("new_trades", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("new_trades_failed", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("paired_trades", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("paired_trades_failed", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("cancelled_trades", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("cancelled_trades_failed", 0);
                                  _mixpanel
                                      .getPeople()
                                      .increment("purchases", 0);
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
                                  _mixpanel.getPeople().setOnce(
                                      "createdAt", DateTime.now().toString());
                                  _mixpanel.flush();
                                }
                              } catch (error) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
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
        ),
      ),
    );
  }
}
