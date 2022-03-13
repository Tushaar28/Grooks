import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:grooks_dev/widgets/custom_dropdown.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackScreen extends StatefulWidget {
  final Users user;
  const FeedbackScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late List<String> _categories;
  late final FirebaseRepository _repository;
  late String? _selectedCategory;
  late final GlobalKey<FormState> _formKey;
  late ImagePicker _picker;
  late File? _uploadedPhoto;
  late bool _dataLoaded, _isActive, _isLoading, _done;
  final feedbackSuccessSnackbar = const SnackBar(
    content: AutoSizeText('Feedback sent'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  );
  final feedbackFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _isActive = true;
    _isLoading = _dataLoaded = _done = false;
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    _categories = [];
    _formKey = GlobalKey<FormState>();
    _picker = ImagePicker();
    _uploadedPhoto = null;
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<void> sendFeedback() async {
    try {
      await _repository.sendFeedback(
        category: _selectedCategory!,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        user: widget.user,
        image: _uploadedPhoto,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getFeedbackCategories() async {
    try {
      QuerySnapshot data = await _repository.getFeedbackCategories;
      if (data.docs.isNotEmpty) {
        for (var element in data.docs) {
          element.get('categories').forEach((element) {
            int index = _categories.indexWhere((ele) => ele == element);
            if (index == -1) {
              _categories.add(element);
            } else {
              _categories[index] = element;
            }
          });
        }
      }
      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  void uploadPhoto({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 256,
        maxWidth: 256,
      );
      if (pickedFile != null) {
        setState(() => _uploadedPhoto = File(pickedFile.path));
      }
    } catch (error) {}
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
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
      });
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Support',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: FutureBuilder(
              future: getFeedbackCategories(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
                        child: FlutterFlowDropDown(
                          hint: 'Choose Category',
                          initialOption: '',
                          fillColor: Colors.blueAccent[50],
                          hideUnderline: false,
                          options: _categories,
                          onChanged: (value) {
                            SchedulerBinding.instance!
                                .addPostFrameCallback((timeStamp) {
                              setState(() => _selectedCategory = value);
                            });
                          },
                          width: double.infinity,
                          height: 40,
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          elevation: 10,
                          borderColor: Colors.black45,
                          borderWidth: 2,
                          borderRadius: 10,
                          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 50, 5, 0),
                        child: TextFormField(
                          controller: _subjectController,
                          obscureText: false,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            hintText: 'Enter subject',
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
                              borderSide: BorderSide(
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          validator: (value) {
                            return value!.isEmpty
                                ? 'Please enter subject'
                                : null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 50, 5, 0),
                        child: TextFormField(
                          controller: _descriptionController,
                          obscureText: false,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter description',
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
                              borderSide: BorderSide(
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          validator: (String? value) {
                            return value!.isEmpty
                                ? 'Please enter description'
                                : null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              child: const Text(
                                "Upload photo",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () async {
                                uploadPhoto(
                                  context: context,
                                  source: ImageSource.gallery,
                                );
                              },
                            ),
                            Text(
                              _uploadedPhoto == null
                                  ? "No file is selected"
                                  : "Image attached",
                              style: TextStyle(
                                color: _uploadedPhoto == null
                                    ? Colors.black
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_uploadedPhoto != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: () =>
                                    setState(() => _uploadedPhoto = null),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 60, 5, 0),
                        child: _done
                            ? null
                            : _isLoading
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.white,
                                  )
                                : SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    child: CustomButton(
                                      onPressed: () async {
                                        try {
                                          if (_selectedCategory == null ||
                                              _selectedCategory!.isEmpty) {
                                            throw 'Please choose category';
                                          }
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() => _isLoading = true);
                                            await sendFeedback();
                                            setState(() => _done = true);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                    feedbackSuccessSnackbar);
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 2200),
                                                () => Navigator.of(context)
                                                    .pop());
                                          }
                                        } catch (error) {
                                          setState(() => _isLoading = false);
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          if (error.toString() ==
                                              'Please choose category') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: AutoSizeText(
                                                    'Please choose category'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                    feedbackFailureSnackbar);
                                          }
                                        }
                                      },
                                      text: "Submit",
                                      textStyle: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
