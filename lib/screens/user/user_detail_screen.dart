import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/set_password_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:page_transition/page_transition.dart';

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
                      top: MediaQuery.of(context).size.height * 0.04,
                    ),
                    child: const AutoSizeText(
                      'Your information',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.08,
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
                        MediaQuery.of(context).size.height * 0.06,
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
                        MediaQuery.of(context).size.height * 0.04,
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
                        MediaQuery.of(context).size.height * 0.04,
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
                        MediaQuery.of(context).size.height * 0.04,
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
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
                                if (_formKey.currentState!.validate()) {
                                  Navigator.of(context).push(
                                    PageTransition(
                                      child: SetPasswordScreen(
                                        name: _lastNameController
                                                .text.isNotEmpty
                                            ? _firstNameController.text.trim() +
                                                ' ' +
                                                _lastNameController.text
                                            : _firstNameController.text.trim(),
                                        phoneNumber: widget.user.phoneNumber!,
                                        referralCode:
                                            _referralController.text.trim(),
                                        uid: widget.user.uid,
                                        profilePicture: _profilePicture,
                                        mixpanel: _mixpanel,
                                      ),
                                      type: PageTransitionType.rightToLeft,
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      reverseDuration: const Duration(
                                        milliseconds: 500,
                                      ),
                                    ),
                                  );
                                }
                                setState(() => _isLoading = false);
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
