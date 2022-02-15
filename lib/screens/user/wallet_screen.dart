import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/wallet.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/activity_screen.dart';
import 'package:grooks_dev/screens/user/pan_verification_screen.dart';
import 'package:grooks_dev/screens/user/withdrawl_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:page_transition/page_transition.dart';

class WalletScreen extends StatefulWidget {
  final String userId;
  const WalletScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late bool _isLoading,
      _hasDataLoaded,
      _is250Selected,
      _is500Selected,
      _is1000Selected;
  late int _bonusCoins, _redeemableCoins;
  late int _coinsUsed;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _isLoading = false;
    _hasDataLoaded = false;
    _is1000Selected = _is250Selected = _is500Selected = false;
    _coinsUsed = -1;
    getUserCoins();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> getUserCoins() async {
    try {
      _bonusCoins = await _repository.getUserBonusCoins(userId: widget.userId);
      _redeemableCoins =
          await _repository.getUserRedeemableCoins(userId: widget.userId);
    } catch (error) {
      throw error.toString();
    } finally {
      setState(() => _hasDataLoaded = true);
    }
  }

  Future<void> showRedeemDialog() async {
    try {
      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              child: Column(
                children: [
                  const Text("Choose amount to withdraw"),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      MediaQuery.of(context).size.height * 0.02,
                      0,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text(
                            "Rs 250",
                            style: TextStyle(
                              color:
                                  _is250Selected ? Colors.blue : Colors.black,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _coinsUsed = 2500;
                              _is250Selected = true;
                              _is1000Selected = false;
                              _is500Selected = false;
                            });
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Rs 500",
                            style: TextStyle(
                              color:
                                  _is500Selected ? Colors.blue : Colors.black,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _coinsUsed = 5000;
                              _is250Selected = false;
                              _is1000Selected = false;
                              _is500Selected = true;
                            });
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Rs 1000",
                            style: TextStyle(
                              color:
                                  _is1000Selected ? Colors.blue : Colors.black,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _coinsUsed = 10000;
                              _is250Selected = false;
                              _is1000Selected = true;
                              _is500Selected = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_coinsUsed != -1)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.02,
                        0,
                        0,
                      ),
                      child: Text("Coins to be used: $_coinsUsed"),
                    ),
                  if (_coinsUsed != -1 && _redeemableCoins >= _coinsUsed)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.02,
                        0,
                        0,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ))
                          : CustomButton(
                              onPressed: () async {
                                try {
                                  setState(() => _isLoading = true);
                                  bool _isPanVerified = await _repository
                                      .getPanVerificationStatus(
                                          userId: widget.userId);
                                  if (_isPanVerified == false) {
                                    Navigator.of(context).push(
                                      PageTransition(
                                        child: WithdrawlScreen(
                                          userId: widget.userId,
                                          amount: _coinsUsed / 10,
                                        ),
                                        type: PageTransitionType.rightToLeft,
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      PageTransition(
                                        child: WithdrawlScreen(
                                          userId: widget.userId,
                                          amount: _coinsUsed / 10,
                                        ),
                                        type: PageTransitionType.rightToLeft,
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  Navigator.of(context).pop();
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                              text: "CONTINUE",
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Wallet',
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
      body: !_hasDataLoaded
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            )
          : SafeArea(
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: Card(
                          elevation: 10,
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  MediaQuery.of(context).size.height * 0.025,
                                  0,
                                  0,
                                ),
                                child: Center(
                                  child: Text(
                                    "${_bonusCoins + _redeemableCoins} coins",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  MediaQuery.of(context).size.height * 0.01,
                                  0,
                                  0,
                                ),
                                child: Text(
                                    "($_redeemableCoins coins can be redeemed)"),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              CustomButton(
                                onPressed: () async {
                                  await showRedeemDialog();
                                },
                                text: "REDEEM",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    Card(
                      elevation: 10,
                      child: ListTile(
                        isThreeLine: false,
                        dense: false,
                        title: const Text("Recent Activities"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.of(context).push(
                          PageTransition(
                            child: ActivityScreen(
                              userId: widget.userId,
                            ),
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            reverseDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
