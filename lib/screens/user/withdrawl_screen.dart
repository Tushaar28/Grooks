import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:grooks_dev/widgets/custom_dropdown.dart';

class WithdrawlScreen extends StatefulWidget {
  final String userId;
  final double amount;
  const WithdrawlScreen({
    required this.userId,
    required this.amount,
    Key? key,
  }) : super(key: key);

  @override
  _WithdrawlScreenState createState() => _WithdrawlScreenState();
}

class _WithdrawlScreenState extends State<WithdrawlScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late final GlobalKey<FormState> _formKey;
  late String _withdrawlMethod;
  late bool? _isActive;
  late bool _isLoading;
  late final TextEditingController _accountController,
      _confirmAccountController,
      _ifscController,
      _upiController;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _withdrawlMethod = '';
    _isLoading = false;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _formKey = GlobalKey<FormState>();
    _accountController = TextEditingController();
    _confirmAccountController = TextEditingController();
    _ifscController = TextEditingController();
    _upiController = TextEditingController();
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
  }

  Future<void> sendWithdrawlRequest() async {
    try {
      if (_withdrawlMethod.toLowerCase() == "upi") {
        await _repository.sendWithdrawlRequest(
          userId: widget.userId,
          amount: widget.amount,
          upi: _upiController.text.toLowerCase().trim(),
        );
      } else {
        await _repository.sendWithdrawlRequest(
          userId: widget.userId,
          amount: widget.amount,
          accountNumber: _accountController.text.trim().trim(),
          ifscCode: _ifscController.text.trim(),
        );
      }
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
    } else if (_isActive == false) {
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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Withdrawl',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Colors.black,
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              TextFormField(
                readOnly: true,
                initialValue: widget.amount.toString(),
                obscureText: false,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Amount',
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
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              FlutterFlowDropDown(
                hint: 'Choose Withdrawl Method',
                initialOption: '',
                fillColor: Colors.blueAccent[50],
                hideUnderline: false,
                options: const ["Bank transfer", "UPI"],
                onChanged: (value) {
                  SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
                    setState(() => _withdrawlMethod = value!);
                  });
                },
                width: double.infinity,
                height: 40,
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 16,
                ),
                elevation: 10,
                borderColor: Colors.black87,
                borderWidth: 1,
                borderRadius: 10,
                margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              if (_withdrawlMethod.toLowerCase() == "bank transfer") ...[
                TextFormField(
                  controller: _accountController,
                  readOnly: false,
                  obscureText: false,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
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
                    if (value == null) return "Invalid Account number";
                    // RegExp regex = RegExp("d{9,18}");
                    // if (!regex.hasMatch(value)) return "Invalid Account number";
                    return null;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                TextFormField(
                  readOnly: false,
                  obscureText: false,
                  controller: _confirmAccountController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Confirm Account Number',
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
                    if (value == null) return "Invalid Account number";
                    if (value != _accountController.text) {
                      return "Account Number do not match";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                TextFormField(
                  readOnly: false,
                  obscureText: false,
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
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
                    if (value == null) return "Invalid IFSC Code";
                    RegExp regex = RegExp("[A-Z]{4}0[A-Z0-9]{6}");
                    if (!regex.hasMatch(value)) return "Invalid IFSC Code";
                    return null;
                  },
                ),
              ],
              if (_withdrawlMethod.toLowerCase() == "upi") ...[
                TextFormField(
                  controller: _upiController,
                  readOnly: false,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'Enter your UPI ID',
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
                    if (value == null || value.isEmpty) return "Invalid UPI ID";
                    return null;
                  },
                ),
              ],
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
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
                        text: "WITHDRAW",
                        onPressed: () async {
                          try {
                            if (_withdrawlMethod.isEmpty) {
                              throw "Choose withdrawl method";
                            }
                            if (_formKey.currentState!.validate() == false) {
                              throw "An error occured";
                            }
                            setState(() => _isLoading = true);
                            await sendWithdrawlRequest();
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Your request has been received."),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } catch (error) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if (error.toString() == "Choose withdrawl method") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please choose withdrawl method"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
