import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:image_picker/image_picker.dart';

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
  late Users? _user;
  late final FirebaseRepository _repository;
  late File? _newProfilePicture;
  late ImagePicker _picker;
  late PickedFile? _imageFile;
  dynamic _pickImageError;
  late bool _isLoading, _done;
  late bool? _isActive;
  late bool _dataLoaded;

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
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _dataLoaded = false;
    _isActive = null;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _nameController = TextEditingController();
    getUserDetails();
    _isLoading = _done = false;
    _picker = ImagePicker();
    _newProfilePicture = null;
    _imageFile = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                        if (_newProfilePicture == null &&
                            widget.user.name.trim() ==
                                _nameController.text.trim()) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No changes to save"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        setState(() => _isLoading = true);
                        await updateUser();
                        setState(() {
                          _isLoading = false;
                          _done = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(updateSuccessSnackbar);
                      } catch (error) {
                        setState(() {
                          _isLoading = false;
                          _done = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(updateFailureSnackbar);
                      } finally {
                        Future.delayed(
                            const Duration(seconds: 2),
                            () => Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => NavbarScreen(),
                                ),
                                (route) => false));
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
        child: Align(
          alignment: const Alignment(0, 0),
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
                              padding: const EdgeInsets.fromLTRB(5, 55, 5, 5),
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
      ),
    );
  }
}
