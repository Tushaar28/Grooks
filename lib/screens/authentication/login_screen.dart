import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';

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
  late final GlobalKey<FormState> _formState;
  late final FirebaseRepository _repository;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _repository = FirebaseRepository();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formState = GlobalKey<FormState>();
    _isLoading = false;
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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFEDECEC),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextField(
                        controller: _mobileController,
                        obscureText: false,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter phone number',
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.053,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: const Text(
                          "Send OTP",
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
                                builder: (context) => OTPInputWidget(
                                  mobile: _mobileController.text.trim(),
                                  referralCode: '',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.grey,
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.42,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.height * 0.03,
                          child: const Center(
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.grey,
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.415,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.07,
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              "assets/images/google.svg",
                              fit: BoxFit.contain,
                            ),
                          ),
                          onTap: () async {
                            UserCredential user =
                                await _repository.signInWithGoogle();
                            Users? userDetails =
                                await _repository.getUserDetails();
                            if (userDetails != null &&
                                userDetails.isActive == false) {
                              await _repository.signOut();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Your account has been suspended",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (userDetails == null ||
                                user.additionalUserInfo!.isNewUser) {
                              await _repository.addUser(
                                name: user.user!.displayName!,
                                uid: user.user!.uid,
                                mobile: user.user!.phoneNumber,
                                profileUrl: user.user!.photoURL,
                                email: user.user!.email!,
                              );
                            }
                            if (userDetails != null) {
                              userDetails = await _repository.getUserDetails();
                            }
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavBarWidget(
                                  user: userDetails,
                                  initialPage: 'Home',
                                ),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
