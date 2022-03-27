import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final Users user;
  const EditProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late Users? _user;
  late final FirebaseRepository _repository;
  late File? _newProfilePicture;
  late ImagePicker _picker;
  late PickedFile? _imageFile;
  dynamic _pickImageError;
  late bool _isLoading, _done;
  late bool? _isActive;
  late bool _dataLoaded, _setPassword, _changePassword;
  late Mixpanel _mixpanel;

  final updateSuccessSnackbar = const SnackBar(
    content: AutoSizeText('Details updated'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  );
  final updateFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured. Please try again.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _dataLoaded = false;
    _setPassword = false;
    _changePassword = false;
    _isActive = null;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    getUserDetails();
    _isLoading = _done = false;
    _picker = ImagePicker();
    _newProfilePicture = null;
    _imageFile = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("edit_profile_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Widget getProfilePicture() {
    if (_newProfilePicture != null) {
      return ClipOval(
        child: Image.file(
          _newProfilePicture!,
          fit: BoxFit.cover,
        ),
      );
    }
    if (_user!.image == null) {
      return ClipOval(
        child: Image.asset(
          "assets/images/user.png",
          fit: BoxFit.cover,
        ),
      );
    }
    return ClipOval(
      child: FadeInImage.assetNetwork(
        placeholder: "assets/images/user.png",
        image: _user!.image!,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<void> getUserDetails() async {
    try {
      _user = await _repository.getUserDetails(userId: widget.user.id);
      if (_user == null) {
        throw "An error occured";
      }
      _nameController.text = _user!.name;
      setState(() => _dataLoaded = true);
    } catch (error) {
      rethrow;
    }
  }

  void _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
  }) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxHeight: 150,
        maxWidth: 150,
        imageQuality: 50,
      );
      setState(() {
        _imageFile = pickedFile;
        _newProfilePicture = File(_imageFile!.path);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> updateUser() async {
    try {
      Map<String, dynamic> data = {};
      data['name'] = _nameController.text;

      if (_newProfilePicture != null) {
        data['image'] = _newProfilePicture;
      }
      await _repository.updateUser(
        userId: widget.user.id,
        data: data,
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    if (_isActive == false) {
      _repository.signOut();
      SchedulerBinding.instance!.addPostFrameCallback(
        (timeStamp) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      );
    }
    if (_dataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
            child: _isLoading || _done
                ? null
                : TextButton(
                    onPressed: () async {
                      try {
                        if (_setPassword == true || _changePassword == true) {
                          if (_passwordController.text.trim().length != 4) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password is required"),
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
                                content:
                                    Text("Password should contain 4 digits"),
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
                                content: Text("Password do not match"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                        }
                        setState(() => _isLoading = true);
                        await updateUser();
                        setState(() {
                          _isLoading = false;
                          _done = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(updateSuccessSnackbar);
                        Future.delayed(
                          const Duration(seconds: 1),
                          () => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => NavbarScreen(),
                              ),
                              (route) => false),
                        );
                      } catch (error) {
                        setState(() {
                          _isLoading = false;
                          _done = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(updateFailureSnackbar);
                      }
                    },
                    child: AutoSizeText(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: getProfilePicture(),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context, isMultiImage: false);
                    },
                    child: const AutoSizeText('Change Profile Photo'),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 55, 20, 5),
                            child: TextFormField(
                              controller: _nameController,
                              obscureText: false,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                labelText: 'Name',
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              validator: (String? value) {
                                return value!.isEmpty
                                    ? 'Name is required'
                                    : null;
                              },
                            ),
                          ),
                          // SizedBox(
                          //   height: MediaQuery.of(context).size.height * 0.07,
                          // ),
                          // if (_user!.password != null) ...[
                          //   Center(
                          //     child: Column(
                          //       children: [
                          //         if (_changePassword == false) ...[
                          //           TextButton(
                          //             child: const Text(
                          //               "Change Password",
                          //               style: TextStyle(
                          //                 fontSize: 18,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //             onPressed: () => setState(() =>
                          //                 _changePassword = !_changePassword),
                          //           ),
                          //         ],
                          //         if (_changePassword == true) ...[
                          //           const Padding(
                          //             padding: EdgeInsets.only(
                          //               top: 20,
                          //             ),
                          //             child: Center(
                          //               child: Text(
                          //                 "Your old password",
                          //                 style: TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             child: Padding(
                          //               padding: const EdgeInsets.fromLTRB(
                          //                   0, 10, 0, 10),
                          //               child: OTPTextField(
                          //                 keyboardType: TextInputType.phone,
                          //                 obscureText: true,
                          //                 length: 4,
                          //                 width:
                          //                     MediaQuery.of(context).size.width,
                          //                 fieldWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width *
                          //                     0.13,
                          //                 otpFieldStyle: OtpFieldStyle(
                          //                   backgroundColor: Colors.white,
                          //                   borderColor: Colors.black,
                          //                   enabledBorderColor: Colors.black,
                          //                   focusBorderColor: Colors.black,
                          //                 ),
                          //                 style: const TextStyle(
                          //                   fontSize: 18,
                          //                   color: Colors.black,
                          //                 ),
                          //                 textFieldAlignment:
                          //                     MainAxisAlignment.spaceAround,
                          //                 fieldStyle: FieldStyle.underline,
                          //                 onChanged: (String value) {
                          //                   _passwordController.text = value;
                          //                 },
                          //                 onCompleted: (String pin) {
                          //                   _passwordController.text =
                          //                       pin.trim();
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //           const Padding(
                          //             padding: EdgeInsets.only(
                          //               top: 20,
                          //             ),
                          //             child: Center(
                          //               child: Text(
                          //                 "Set your 4 digit password",
                          //                 style: TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             child: Padding(
                          //               padding: const EdgeInsets.fromLTRB(
                          //                   0, 10, 0, 10),
                          //               child: OTPTextField(
                          //                 keyboardType: TextInputType.phone,
                          //                 obscureText: true,
                          //                 length: 4,
                          //                 width:
                          //                     MediaQuery.of(context).size.width,
                          //                 fieldWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width *
                          //                     0.13,
                          //                 otpFieldStyle: OtpFieldStyle(
                          //                   backgroundColor: Colors.white,
                          //                   borderColor: Colors.black,
                          //                   enabledBorderColor: Colors.black,
                          //                   focusBorderColor: Colors.black,
                          //                 ),
                          //                 style: const TextStyle(
                          //                   fontSize: 18,
                          //                   color: Colors.black,
                          //                 ),
                          //                 textFieldAlignment:
                          //                     MainAxisAlignment.spaceAround,
                          //                 fieldStyle: FieldStyle.underline,
                          //                 onChanged: (String value) {
                          //                   _passwordController.text = value;
                          //                 },
                          //                 onCompleted: (String pin) {
                          //                   _passwordController.text =
                          //                       pin.trim();
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //           const Padding(
                          //             padding: EdgeInsets.only(
                          //               top: 20,
                          //             ),
                          //             child: Center(
                          //               child: Text(
                          //                 "Confirm your 4 digit password",
                          //                 style: TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             child: Padding(
                          //               padding: const EdgeInsets.fromLTRB(
                          //                   0, 10, 0, 10),
                          //               child: OTPTextField(
                          //                 keyboardType: TextInputType.phone,
                          //                 obscureText: true,
                          //                 length: 4,
                          //                 width:
                          //                     MediaQuery.of(context).size.width,
                          //                 fieldWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width *
                          //                     0.13,
                          //                 otpFieldStyle: OtpFieldStyle(
                          //                   backgroundColor: Colors.white,
                          //                   borderColor: Colors.black,
                          //                   enabledBorderColor: Colors.black,
                          //                   focusBorderColor: Colors.black,
                          //                 ),
                          //                 style: const TextStyle(
                          //                   fontSize: 18,
                          //                   color: Colors.black,
                          //                 ),
                          //                 textFieldAlignment:
                          //                     MainAxisAlignment.spaceAround,
                          //                 fieldStyle: FieldStyle.underline,
                          //                 onChanged: (String value) {
                          //                   _confirmPasswordController.text =
                          //                       value;
                          //                 },
                          //                 onCompleted: (String pin) {
                          //                   _confirmPasswordController.text =
                          //                       pin.trim();
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ],
                          //     ),
                          //   ),
                          // ],
                          // if (_user!.password == null) ...[
                          //   Center(
                          //     child: Column(
                          //       children: [
                          //         if (_setPassword == false) ...[
                          //           TextButton(
                          //             child: const Text(
                          //               "Set Password",
                          //               style: TextStyle(
                          //                 fontSize: 18,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //             onPressed: () => setState(
                          //                 () => _setPassword = !_setPassword),
                          //           ),
                          //         ],
                          //         if (_setPassword == true) ...[
                          //           const Padding(
                          //             padding: EdgeInsets.only(
                          //               top: 20,
                          //             ),
                          //             child: Center(
                          //               child: Text(
                          //                 "Set your 4 digit password",
                          //                 style: TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             child: Padding(
                          //               padding: const EdgeInsets.fromLTRB(
                          //                   0, 10, 0, 10),
                          //               child: OTPTextField(
                          //                 keyboardType: TextInputType.phone,
                          //                 obscureText: true,
                          //                 length: 4,
                          //                 width:
                          //                     MediaQuery.of(context).size.width,
                          //                 fieldWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width *
                          //                     0.13,
                          //                 otpFieldStyle: OtpFieldStyle(
                          //                   backgroundColor: Colors.white,
                          //                   borderColor: Colors.black,
                          //                   enabledBorderColor: Colors.black,
                          //                   focusBorderColor: Colors.black,
                          //                 ),
                          //                 style: const TextStyle(
                          //                   fontSize: 18,
                          //                   color: Colors.black,
                          //                 ),
                          //                 textFieldAlignment:
                          //                     MainAxisAlignment.spaceAround,
                          //                 fieldStyle: FieldStyle.underline,
                          //                 onChanged: (String value) {
                          //                   _passwordController.text = value;
                          //                 },
                          //                 onCompleted: (String pin) {
                          //                   _passwordController.text =
                          //                       pin.trim();
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //           const Padding(
                          //             padding: EdgeInsets.only(
                          //               top: 20,
                          //             ),
                          //             child: Center(
                          //               child: Text(
                          //                 "Confirm your 4 digit password",
                          //                 style: TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             child: Padding(
                          //               padding: const EdgeInsets.fromLTRB(
                          //                   0, 10, 0, 10),
                          //               child: OTPTextField(
                          //                 keyboardType: TextInputType.phone,
                          //                 obscureText: true,
                          //                 length: 4,
                          //                 width:
                          //                     MediaQuery.of(context).size.width,
                          //                 fieldWidth: MediaQuery.of(context)
                          //                         .size
                          //                         .width *
                          //                     0.13,
                          //                 otpFieldStyle: OtpFieldStyle(
                          //                   backgroundColor: Colors.white,
                          //                   borderColor: Colors.black,
                          //                   enabledBorderColor: Colors.black,
                          //                   focusBorderColor: Colors.black,
                          //                 ),
                          //                 style: const TextStyle(
                          //                   fontSize: 18,
                          //                   color: Colors.black,
                          //                 ),
                          //                 textFieldAlignment:
                          //                     MainAxisAlignment.spaceAround,
                          //                 fieldStyle: FieldStyle.underline,
                          //                 onChanged: (String value) {
                          //                   _confirmPasswordController.text =
                          //                       value;
                          //                 },
                          //                 onCompleted: (String pin) {
                          //                   _confirmPasswordController.text =
                          //                       pin.trim();
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ],
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
