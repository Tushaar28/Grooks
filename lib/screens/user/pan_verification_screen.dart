import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/account_information_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';

class PanVerificationScreen extends StatefulWidget {
  final String userId;
  final double requestedAmount;
  final double finalAmount;
  late double commission;
  final int coins;
  PanVerificationScreen({
    Key? key,
    required this.userId,
    required this.requestedAmount,
    required this.finalAmount,
    required this.commission,
    required this.coins,
  }) : super(key: key);

  @override
  _PanVerificationScreenState createState() => _PanVerificationScreenState();
}

class _PanVerificationScreenState extends State<PanVerificationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FirebaseRepository _repository;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _panController, _nameController;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _formKey = GlobalKey<FormState>();
    _panController = TextEditingController();
    _nameController = TextEditingController();
    _isLoading = false;
  }

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool isPanValid(Map<String, dynamic> data) {
    bool isNameMatch = data["registered_name"]
            .toString()
            .toLowerCase()
            .compareTo(data["name_provided"].toString().toLowerCase()) ==
        0;

    bool isPanTypeIndividual =
        data["type"].toString().toLowerCase().compareTo("individual") == 0;

    bool isMessageSuccess = data["message"]
            .toString()
            .toLowerCase()
            .compareTo("pan verified successfully") ==
        0;

    return isNameMatch && isPanTypeIndividual && isMessageSuccess;
  }

  Future<void> updatePanVerificationStatus() async {
    try {
      await _repository.updatePanVerificationStatus(
        userId: widget.userId,
        pan: _panController.text.trim().toUpperCase(),
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Pan Verification',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
          ),
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const Center(
                  child: Text(
                    "Enter your PAN details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                TextFormField(
                  controller: _panController,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'PAN Number',
                    hintText: "Enter PAN Number",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
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
                  validator: (String? value) {
                    if (value == null) return "Invalid PAN card";
                    RegExp regex = RegExp("[A-Z]{5}[0-9]{4}[A-Z]{1}");
                    if (!regex.hasMatch(value)) return "Invalid PAN card";
                    return null;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                ),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: "Enter your name as on PAN card",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                SizedBox(
                  width: double.infinity,
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
                                var result = await FirebaseFunctions.instance
                                    .httpsCallable("verifyPAN")
                                    .call({
                                  "pan":
                                      _panController.text.trim().toUpperCase(),
                                  "name": _nameController.text.trim(),
                                });
                                bool isValid = isPanValid(result.data);
                                if (!isValid) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("PAN Verification Failed"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  return;
                                }
                                await updatePanVerificationStatus();
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("PAN Verified"),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                await Future.delayed(const Duration(seconds: 1),
                                    () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AccountInformationScreen(
                                        commission: widget.commission,
                                        finalAmount: widget.finalAmount,
                                        requestedAmount: widget.requestedAmount,
                                        userId: widget.userId,
                                        coins: widget.coins,
                                      ),
                                    ),
                                  );
                                });
                              }
                              setState(() => _isLoading = false);
                            } catch (error) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("An error occured"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          text: "VERIFY",
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
