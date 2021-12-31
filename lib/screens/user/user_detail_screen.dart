import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/constants/constants.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/my_encryption.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';

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
  late final ImagePicker _picker;
  late File? _profilePicture;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final GlobalKey<FormState> _formKey;
  late final FirebaseRepository _repository;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _picker = ImagePicker();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formKey = GlobalKey<FormState>();
    _repository = FirebaseRepository();
    _isLoading = false;
    _profilePicture = null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<String> generateReferralCode(
      String userName, String userMobile) async {
    var id = MyEncryptionDecryption.encryptAES(userMobile);
    var randomCode = "${userName.substring(0, 3)}-${id.base64.substring(0, 8)}";
    return randomCode;
  }

  Future<void> saveReferralLink(String link) async {
    _repository.saveReferalLink(link);
  }

  Future<void> addUser() async {
    try {
      String name = _lastNameController.text.isNotEmpty
          ? _firstNameController.text + ' ' + _lastNameController.text
          : _firstNameController.text;

      await _repository.addUser(
        name: name,
        mobile: widget.user.phoneNumber,
        uid: widget.user.uid,
        profilePicture: _profilePicture,
        referralCode: widget.referralCode,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: AutoSizeText(
                        APP_NAME,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: AutoSizeText(
                        'Your information',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                _profilePicture == null ? Colors.grey : null,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                      child: TextFormField(
                        controller: _firstNameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightBlueAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                        validator: (String? value) {
                          return value!.isEmpty
                              ? 'First name is required'
                              : null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: TextFormField(
                        controller: _lastNameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightBlueAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: TextFormField(
                        readOnly: true,
                        initialValue: widget.user.phoneNumber,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightBlueAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),
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
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
                                    await addUser();
                                    Users? user = await getUserDetails();
                                    var referalCode =
                                        await generateReferralCode(
                                            user!.name, user.mobile!);

                                    saveReferralLink(referalCode);
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
                                  }
                                } catch (error) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('An error occured'),
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
      ),
    );
  }
}
