import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/pan_verification_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'account_information_screen.dart';

class WithdrawlScreen extends StatefulWidget {
  final String userId;
  WithdrawlScreen({
    Key? key,
    required this.userId,
  })  : assert(userId.isNotEmpty),
        super(key: key);

  @override
  State<WithdrawlScreen> createState() => _WithdrawlScreenState();
}

class _WithdrawlScreenState extends State<WithdrawlScreen> {
  Users? _user;
  late bool _isLoading, _dataLoaded;
  bool? _isActive;
  late final FirebaseRepository _repository;
  int? _bonusCoins, _redeemableCoins;
  late TextEditingController _amountController;
  late double _payoutCommission;
  late final Mixpanel _mixpanel;
  late int _withdrawlLimit;
  late int _withdrawlPeriod;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _payoutCommission = 0;
    _withdrawlLimit = 0;
    _bonusCoins = _redeemableCoins = 0;
    _repository = FirebaseRepository();
    _isLoading = false;
    _dataLoaded = false;
    getUserActiveStatus();
    getUserDetails();
    getUserCoins();
    getWithdrawlLimit();
    getWithdrawlPeriod();
    getPayoutCommission();
    _amountController = TextEditingController();
    _amountController.text = "0";
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
    _amountController.dispose();
    super.dispose();
  }

  Future<void> getUserActiveStatus() async {
    try {
      bool status =
          await _repository.getUserActiveStatus(userId: widget.userId);
      setState(() => _isActive = status);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getWithdrawlLimit() async {
    try {
      int limit = await _repository.getWithdrawlLimit;
      _withdrawlLimit = limit;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getWithdrawlPeriod() async {
    try {
      int period = await _repository.getWithdrawlPeriod;
      _withdrawlPeriod = period;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserDetails() async {
    try {
      Users? user = await _repository.getUserDetails(userId: widget.userId);
      if (user == null) {
        throw "An error occured";
      }
      setState(() {
        _user = user;
      });
    } catch (error) {
      rethrow;
    }
  }

  bool isAmountValid() {
    try {
      double? amount = double.tryParse(_amountController.text);
      if (amount == null) return false;
      return amount >= _withdrawlLimit;
    } catch (error) {
      return false;
    }
  }

  Future<void> getUserCoins() async {
    try {
      int bonusCoins =
          await _repository.getUserBonusCoins(userId: widget.userId);
      int redeemableCoins =
          await _repository.getUserRedeemableCoins(userId: widget.userId);
      setState(() {
        _bonusCoins = bonusCoins;
        _redeemableCoins = redeemableCoins;
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getPayoutCommission() async {
    try {
      double commission = await _repository.getPayoutCommission;
      setState(() {
        _payoutCommission = commission;
        _dataLoaded = true;
      });
    } catch (error) {
      rethrow;
    }
  }

  double getWithdrawlCharges() {
    return (_payoutCommission / 100 * double.parse(_amountController.text));
  }

  double getFinalAmount() {
    return double.parse(_amountController.text) - getWithdrawlCharges();
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null || _user == null || _dataLoaded == false) {
      return const Center(
          child: CircularProgressIndicator.adaptive(
        backgroundColor: Colors.white,
      ));
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: const AutoSizeText(
            'Withdraw',
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
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
          ),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.03,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AutoSizeText(
                              "Total Coins ",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.07,
                            ),
                            AutoSizeText(
                              "${_bonusCoins! + _redeemableCoins!}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Image.asset("assets/images/coins.png"),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              "$_redeemableCoins ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                            const AutoSizeText(
                              "coins can be redeemed.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              const AutoSizeText("PAN Verification is mandatory for withdrawl"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              const AutoSizeText("Rs.10 = 100 coins"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              AutoSizeText("Minimum Rs $_withdrawlLimit can be redeemed"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              AutoSizeText(
                  "There has to be a gap of atleast $_withdrawlPeriod days between consecutive withdrawls"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                obscureText: false,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Enter amount (Minimum Rs $_withdrawlLimit)',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                padding: EdgeInsets.fromLTRB(
                  0,
                  MediaQuery.of(context).size.height * 0.01,
                  0,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: const AutoSizeText(
                            "Coins to be used",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: AutoSizeText(
                              "${double.parse(_amountController.text).ceil() * 10}",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: const AutoSizeText(
                            "Withdrawl charges",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: AutoSizeText(
                                "Rs ${getWithdrawlCharges().toStringAsFixed(2)}"),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: const AutoSizeText(
                            "Final Amount",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: AutoSizeText("Rs ${getFinalAmount()}"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : SwipeButton(
                              text: "Swipe to Withdraw",
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              color: Theme.of(context).primaryColor,
                              backgroundColorEnd: Colors.blueAccent[100],
                              onSwipeCallback: () async {
                                try {
                                  setState(() => _isLoading = true);
                                  bool isValid = isAmountValid();
                                  if (isValid == false) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            AutoSizeText("Insufficient amount"),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    setState(() => _isLoading = false);
                                    return;
                                  }
                                  bool isPanVerified = await _repository
                                      .getPanVerificationStatus(
                                          userId: widget.userId);
                                  if (isPanVerified) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccountInformationScreen(
                                          requestedAmount: double.parse(
                                              _amountController.text),
                                          finalAmount: getFinalAmount(),
                                          commission: getWithdrawlCharges(),
                                          userId: widget.userId,
                                          coins: double.parse(
                                                      _amountController.text)
                                                  .ceil() *
                                              10,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PanVerificationScreen(
                                          requestedAmount: double.parse(
                                              _amountController.text),
                                          finalAmount: getFinalAmount(),
                                          commission: getWithdrawlCharges(),
                                          userId: widget.userId,
                                          coins: double.parse(
                                                      _amountController.text)
                                                  .ceil() *
                                              10,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: AutoSizeText("An error occured"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
