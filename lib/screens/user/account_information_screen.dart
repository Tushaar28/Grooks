import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_dropdown.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AccountInformationScreen extends StatefulWidget {
  final String userId;
  final double requestedAmount;
  final double finalAmount;
  late double commission;
  final int coins;
  AccountInformationScreen({
    Key? key,
    required this.userId,
    required this.requestedAmount,
    required this.finalAmount,
    required this.commission,
    required this.coins,
  }) : super(key: key);

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FirebaseRepository _repository;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _upiController,
      _nameController,
      _accountController,
      _confirmAccountController,
      _ifscController;
  late bool _isLoading,
      _done,
      _isUpiValid,
      _isBankValid,
      _isUpiVerified,
      _isBankVerified;
  String? _withdrawlType;
  late Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _repository = FirebaseRepository();
    _formKey = GlobalKey<FormState>();
    _upiController = TextEditingController();
    _nameController = TextEditingController();
    _accountController = TextEditingController();
    _confirmAccountController = TextEditingController();
    _ifscController = TextEditingController();
    _isLoading = _done =
        _isUpiVerified = _isBankVerified = _isUpiValid = _isBankValid = false;
    // _upiController.addListener(isUpiValid);
    // _nameController.addListener(isUpiValid);
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.userId);
    _mixpanel.track("withdrawl_screen", properties: {
      "userId": widget.userId,
    });
  }

  @override
  void dispose() {
    _upiController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  // void isUpiValid() {
  //   Pattern pattern = r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$';
  //   RegExp regex = RegExp(pattern.toString());
  //   if (!regex.hasMatch(_upiController.text.trim()) ||
  //       _nameController.text.trim().isEmpty) {
  //     setState(() => _isUpiValid = false);
  //   } else {
  //     setState(() => _isUpiValid = true);
  //   }
  // }

  Future<void> submitPayoutRequest() async {
    try {
      if (_withdrawlType!.toLowerCase().contains("upi")) {
        await _repository.submitPayoutRequest(
          upi: _upiController.text.trim(),
          requestedAmount: widget.requestedAmount,
          finalAmount: widget.finalAmount,
          commission: widget.commission,
          coins: widget.coins,
          userId: widget.userId,
          name: _nameController.text.trim(),
        );
      } else {
        await _repository.submitPayoutRequest(
          accountNumber: _accountController.text.trim(),
          ifscCode: _ifscController.text.trim(),
          requestedAmount: widget.requestedAmount,
          finalAmount: widget.finalAmount,
          commission: widget.commission,
          coins: widget.coins,
          userId: widget.userId,
          name: _nameController.text.trim(),
        );
      }
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
          'Account Information',
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
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
                  child: FlutterFlowDropDown(
                    hint: 'Choose Withdrawl Type',
                    initialOption: '',
                    fillColor: Colors.blueAccent[50],
                    hideUnderline: false,
                    options: const [
                      "Bank Transfer",
                      "UPI",
                    ],
                    onChanged: (value) {
                      _nameController.text = '';
                      _ifscController.text = '';
                      _accountController.text = '';
                      _confirmAccountController.text = '';
                      _upiController.text = '';
                      SchedulerBinding.instance!
                          .addPostFrameCallback((timeStamp) {
                        setState(() => _withdrawlType = value);
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                ),
                if (_withdrawlType != null &&
                    _withdrawlType!.toLowerCase().contains("upi")) ...[
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Account holder name',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter valid name' : null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  TextFormField(
                    controller: _upiController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'Enter UPI ID',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter UPI ID";
                      }
                      Pattern pattern =
                          r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$';
                      RegExp regex = RegExp(pattern.toString());
                      if (!regex.hasMatch(value)) {
                        return "Invalid UPI ID";
                      }
                      return null;
                    },
                  ),
                  //   if (_isUpiValid) ...[
                  //     SizedBox(
                  //       height: MediaQuery.of(context).size.height * 0.01,
                  //     ),
                  //     Center(
                  //       child: _isUpiVerified
                  //           ? const AutoSizeText(
                  //               "Verified",
                  //               style: TextStyle(
                  //                 fontSize: 16,
                  //                 color: Colors.green,
                  //               ),
                  //             )
                  //           : TextButton(
                  //               child: AutoSizeText(
                  //                 "Verify",
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   color: Theme.of(context).primaryColor,
                  //                 ),
                  //               ),
                  //               onPressed: () async {
                  //                 try {
                  //                   var result = await FirebaseFunctions.instance
                  //                       .httpsCallable("verifyUPI")
                  //                       .call({
                  //                     "name": _nameController.text.trim(),
                  //                     "upi": _upiController.text.trim(),
                  //                   });
                  //                   print("RESULT = $result");
                  //                 } catch (error) {
                  //                   rethrow;
                  //                 }
                  //               },
                  //             ),
                  //     ),
                  //   ],
                ],
                if (_withdrawlType != null &&
                    _withdrawlType!.toLowerCase().contains("bank")) ...[
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Account holder name',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter valid name' : null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.phone,
                    obscureText: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      hintText: 'Enter Account Number',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please enter valid account number'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  TextFormField(
                    controller: _confirmAccountController,
                    keyboardType: TextInputType.phone,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Confirm Account Number',
                      hintText: 'Confirm your Account Number',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Account Number";
                      }
                      Pattern pattern = r'^\d{9,18}$';
                      RegExp regex = RegExp(pattern.toString());
                      if (!regex.hasMatch(value)) {
                        return "Invalid Account Number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  TextFormField(
                    controller: _ifscController,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'IFSC Code',
                      hintText: 'Enter IFSC Code',
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
                        borderSide: BorderSide(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter IFSC Code";
                      }
                      Pattern pattern = r'^[6789]\d{9}$';
                      RegExp regex = RegExp(pattern.toString());
                      if (!regex.hasMatch(value)) {
                        return "Invalid IFSC Code";
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const AutoSizeText(
                        "Amount",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: AutoSizeText(
                          "Rs ${widget.finalAmount}",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const AutoSizeText(
                        "Coins to be used",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: AutoSizeText(
                          "${widget.coins}",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                const AutoSizeText(
                    "It may take upto 24 hours to transfer amount to your account"),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
                SizedBox(
                  child: _done
                      ? null
                      : _isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : SwipeButton(
                              text: "Swipe to confirm",
                              onSwipeCallback: () async {
                                try {
                                  setState(() => _isLoading = true);
                                  if (_withdrawlType == null ||
                                      _withdrawlType!.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: AutoSizeText(
                                            "Please select withdrawl type"),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    setState(() => _isLoading = false);
                                    return;
                                  }
                                  int currentRedeemableCoins =
                                      await _repository.getUserRedeemableCoins(
                                          userId: widget.userId);
                                  if (widget.coins > currentRedeemableCoins) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            AutoSizeText("Insufficient coins"),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    _mixpanel.identify(widget.userId);
                                    _mixpanel
                                        .getPeople()
                                        .increment("payouts_failed", 1);
                                    _mixpanel
                                        .track("payout_failed", properties: {
                                      "userId": widget.userId,
                                    });
                                    setState(() => _isLoading = false);
                                    return;
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    await submitPayoutRequest();
                                    setState(() {
                                      _isLoading = false;
                                      _done = true;
                                    });
                                    _mixpanel.identify(widget.userId);
                                    _mixpanel
                                        .getPeople()
                                        .increment("payouts", 1);
                                    _mixpanel
                                        .track("payout_success", properties: {
                                      "userId": widget.userId,
                                    });
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: AutoSizeText(
                                            "Withdrawl request has been submitted. It may take 24 hours to process your request."),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                      () => Navigator.of(context)
                                          .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NavbarScreen(),
                                              ),
                                              (route) => false),
                                    );
                                  } else {
                                    setState(() => _isLoading = false);
                                  }
                                } catch (error) {
                                  _mixpanel.identify(widget.userId);
                                  _mixpanel
                                      .getPeople()
                                      .increment("payouts_failed", 1);
                                  _mixpanel.track("payout_failed", properties: {
                                    "userId": widget.userId,
                                  });
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: AutoSizeText("An error occured"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              color: Theme.of(context).primaryColor,
                              backgroundColorEnd: Colors.blueAccent[100],
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
