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
  late bool _isLoading,
      _isMobileOrEmailValid,
      _isMobileOrEmailVerified,
      _isActive,
      _done;
  late Users? _receiverUser;
  late final FirebaseRepository _repository;
  late TextEditingController _mobileOrEmailController;
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
  final verificationfailureSnackbar = const SnackBar(
    content: AutoSizeText('Verification failed. Please try again'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _receiverUser = null;
    _transferCommission = 0;
    _userCoins = 0;
    _isLoading = _isMobileOrEmailVerified =
        _isMobileOrEmailValid = _isActive = _done = false;
    _isActive = true;
    _formKey = GlobalKey<FormState>();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _mobileOrEmailController = TextEditingController();
    _coinsController = TextEditingController();
    _mobileOrEmailController.addListener(checkMobileValid);
  }

  @override
  void dispose() {
    _mobileOrEmailController.dispose();
    super.dispose();
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<int> getUserDetails() async {
    try {
      int data =
          await _repository.getUserRedeemableCoins(userId: widget.user.id);
      _userCoins = data;
      double commission = await _repository.getCoinsTransferCommission;
      _transferCommission = commission;
      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<bool> verifyMobileNumberOrEmail() async {
    try {
      Users? data = await _repository.verifyMobileNumberOrEmail(
        value: _mobileOrEmailController.text.trim(),
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
    Pattern mobilePattern = r'^[6789]\d{9}$';
    RegExp mobileRegex = RegExp(mobilePattern.toString());
    Pattern emailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp emailRegex = RegExp(emailPattern.toString());
    if (mobileRegex.hasMatch(_mobileOrEmailController.text.trim())) {
      setState(() => _isMobileOrEmailValid = true);
    } else if (emailRegex.hasMatch(_mobileOrEmailController.text.trim())) {
      setState(() => _isMobileOrEmailValid = true);
    } else {
      setState(() {
        _isMobileOrEmailValid = false;
        _isMobileOrEmailVerified = false;
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
        child: FutureBuilder(
          future: getUserDetails(),
          initialData: const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.white,
            ),
          ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    "assets/images/transfer_coins.png",
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.fromLTRB(
                    0,
                    MediaQuery.of(context).size.height * 0.35,
                    0,
                    0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(
                            "$_userCoins coins available for transfer",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _mobileOrEmailController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Mobile / Email',
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              hintText:
                                  "Enter your friend's mobile number or email address",
                              suffixIcon: _isMobileOrEmailValid
                                  ? _isMobileOrEmailVerified
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
                                                  await verifyMobileNumberOrEmail();
                                              if (isVerified) {
                                                setState(() =>
                                                    _isMobileOrEmailVerified =
                                                        true);
                                              } else {
                                                throw 'Mobile not verified';
                                              }
                                            } catch (error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: AutoSizeText(
                                                      'Verification failed'),
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
                                  Radius.circular(10),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                            validator: (String? value) {},
                          ),
                        ),
                        if (_receiverUser != null) const AutoSizeText(''),
                        if (_isMobileOrEmailVerified && _receiverUser != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: TextFormField(
                              readOnly: true,
                              initialValue: _receiverUser!.name,
                              obscureText: false,
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
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (_receiverUser != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                hintText: 'Enter number of coins to transfer',
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
                          padding: EdgeInsets.fromLTRB(
                              20,
                              MediaQuery.of(context).size.height * 0.015,
                              20,
                              0),
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
                        if (_isMobileOrEmailValid && _isMobileOrEmailVerified)
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
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                                            if (_isMobileOrEmailVerified ==
                                                false) {
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
                                                      verificationfailureSnackbar);
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
              ],
            );
          },
        ),
      ),
    );
  }
}
