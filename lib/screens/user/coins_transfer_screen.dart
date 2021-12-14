import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/activity_screen.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:page_transition/page_transition.dart';

class CoinsTransferScreen extends StatefulWidget {
  final Users user;
  const CoinsTransferScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _CoinsTransferScreenState createState() => _CoinsTransferScreenState();
}

class _CoinsTransferScreenState extends State<CoinsTransferScreen> {
  late int _userCoins;
  late bool _isLoading, _isMobileValid, _isMobileVerified, _isActive, _done;
  late Users? _receiverUser;
  late final FirebaseRepository _repository;
  late TextEditingController _mobileController;
  late TextEditingController _coinsController;
  late final GlobalKey<FormState> _formKey;
  late double _transferCommission;
  final failureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured. Please try agauin'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  final successSnackbar = const SnackBar(
    content: AutoSizeText('Transfer successful'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  );
  final mobileVerificationfailureSnackbar = const SnackBar(
    content: AutoSizeText('Mobile verification failed. Please try again'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _receiverUser = null;
    _transferCommission = 0;
    _isLoading = _isMobileVerified = _isMobileValid = _isActive = _done = false;
    _isActive = true;
    _formKey = GlobalKey<FormState>();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _mobileController = TextEditingController();
    _coinsController = TextEditingController();
    _mobileController.addListener(checkMobileValid);
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<int> getUserDetails() async {
    try {
      int data = await _repository.getUserBonusCoins(userId: widget.user.id);
      _userCoins = data;
      double commission = await _repository.getCoinsTransferCommission;
      _transferCommission = commission;
      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<bool> verifyMobileNumber() async {
    try {
      Users? data = await _repository.verifyMobileNumber(
        mobile: '+91' + _mobileController.text,
      );
      if (data != null && data.id != widget.user.id) {
        setState(() {
          _receiverUser = data;
        });
      }
      return _receiverUser != null;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> transferCoins() async {
    try {
      await _repository.transferCoins(
        senderId: widget.user.id,
        receiverId: _receiverUser!.id,
        senderName: widget.user.name,
        senderMobile: widget.user.mobile,
        receiverName: _receiverUser!.name,
        receiverMobile: _receiverUser!.mobile,
        deductCoins: int.parse(_coinsController.text),
        transferCoins:
            ((1 - _transferCommission / 100) * int.parse(_coinsController.text))
                .floor(),
      );
    } catch (error) {
      rethrow;
    }
  }

  void checkMobileValid() {
    Pattern pattern = r'^[6789]\d{9}$';
    RegExp regex = RegExp(pattern.toString());
    if (regex.hasMatch(_mobileController.text.trim())) {
      setState(() => _isMobileValid = true);
    } else {
      setState(() {
        _isMobileValid = false;
        _isMobileVerified = false;
        _receiverUser = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Transfer Coins',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: getUserDetails(),
            initialData: const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            ),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.3,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/transfer_coins.jpg',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.06,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: const AutoSizeText(
                              'A friend in need is a friend indeed. Help your friends by sharing your coins.',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: _mobileController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              hintText: "Enter your friend's mobile number",
                              suffixIcon: _isMobileValid
                                  ? _isMobileVerified
                                      ? const TextButton(
                                          child: AutoSizeText(
                                            'Verified',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                          onPressed: null,
                                        )
                                      : TextButton(
                                          child: AutoSizeText(
                                            'Verify',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          onPressed: () async {
                                            try {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              bool isVerified =
                                                  await verifyMobileNumber();
                                              if (isVerified) {
                                                setState(() =>
                                                    _isMobileVerified = true);
                                              } else {
                                                throw 'Mobile not verified';
                                              }
                                            } catch (error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: AutoSizeText(
                                                      'Mobile verification failed'),
                                                  backgroundColor: Colors.red,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(32),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.lightBlueAccent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(32),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                            validator: (String? value) {
                              return value!.length != 10
                                  ? 'Enter valid mobile number'
                                  : null;
                            },
                          ),
                        ),
                        if (_receiverUser != null) const AutoSizeText(''),
                        if (_isMobileVerified && _receiverUser != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              readOnly: true,
                              initialValue: _receiverUser!.name,
                              obscureText: false,
                              decoration: const InputDecoration(
                                labelText: 'Name',
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
                                      color: Colors.lightBlueAccent,
                                      width: 2.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32.0)),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (_receiverUser != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: _coinsController,
                              obscureText: false,
                              onChanged: (value) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Coins',
                                hintText: 'Enter number of coins to transfer',
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
                                      color: Colors.lightBlueAccent,
                                      width: 2.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32.0)),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                              validator: (String? value) {
                                try {
                                  int coins = int.tryParse(value!)!;
                                  if (coins > _userCoins) {
                                    return 'Insufficient coins';
                                  }
                                  return null;
                                } on FormatException catch (_) {
                                  return 'Invalid amount';
                                }
                              },
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20,
                              MediaQuery.of(context).size.height * 0.05, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: AutoSizeText(
                                  'Transfer charges ($_transferCommission%)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: AutoSizeText(
                                    _coinsController.text.isEmpty
                                        ? '0'
                                        : '${(int.parse(_coinsController.text) * _transferCommission / 100).ceil()}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (_isMobileValid && _isMobileVerified)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: const AutoSizeText(
                                    'Final Coins to be transferred',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: AutoSizeText(
                                      _coinsController.text.isEmpty
                                          ? '0'
                                          : '${(int.parse(_coinsController.text) * (1 - (_transferCommission / 100))).floor()}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (_coinsController.text.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                            child: _isLoading
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.white,
                                  )
                                : _done
                                    ? const SizedBox()
                                    : SwipeButton(
                                        backgroundColorEnd:
                                            Colors.blueAccent[100],
                                        color: Theme.of(context).primaryColor,
                                        width: 300,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        text: 'Swipe to transfer',
                                        onSwipeCallback: () async {
                                          try {
                                            if (_isMobileVerified == false) {
                                              throw 'Mobile number not verified';
                                            }
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() => _isLoading = true);
                                              await transferCoins();

                                              ScaffoldMessenger.of(context)
                                                  .hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                      successSnackbar);
                                              Future.delayed(
                                                const Duration(
                                                    milliseconds: 2100),
                                                () => Navigator.pushReplacement(
                                                  context,
                                                  PageTransition(
                                                    child: ActivityScreen(
                                                      userId: widget.user.id,
                                                      chosenOption: 'Transfers',
                                                    ),
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    reverseDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            if (error.toString() ==
                                                'Mobile number not verified') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                      mobileVerificationfailureSnackbar);
                                            } else if (error.toString() ==
                                                'Insufficient coins') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Insufficient coins"),
                                                  backgroundColor: Colors.red,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                      failureSnackbar);
                                            }
                                            setState(() {});
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                      ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
