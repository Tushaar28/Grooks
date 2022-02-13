import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/activity_screen.dart';
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
  late bool _isLoading, _hasDataLoaded;
  late int _bonusCoins, _redeemableCoins;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _isLoading = false;
    _hasDataLoaded = false;
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
                                onPressed: () {},
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
