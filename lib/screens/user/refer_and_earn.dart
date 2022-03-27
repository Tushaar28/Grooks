import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/dynamic_link.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'error_screen.dart';

class ReferralWidget extends StatefulWidget {
  final Users user;
  const ReferralWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ReferralWidgetState createState() => _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
  late final FirebaseRepository repository;
  DynamicLinkApi dynamicLink = DynamicLinkApi();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final copySuccessSnakbar = const SnackBar(
    content: AutoSizeText('Copied'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  );
  final failureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  bool _isLoading = false, _dataLoaded = false;
  String code = "";
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isLoading = false;
    repository = FirebaseRepository();
    getUserReferralCode();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("refer_and_earn_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Future<void> getUserReferralCode() async {
    try {
      code = await repository.getUserReferralCode(
        userId: widget.user.id,
      );
      setState(() => _dataLoaded = true);
    } catch (error) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ErrorScreen(
            user: widget.user,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Refer and earn',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                "assets/images/refer.png",
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).size.height * 0.35,
                0,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: const Center(
                      child: AutoSizeText(
                        'Refer your friends and earn 500 coins on every successful referral',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: AutoSizeText(
                        'Your Referral code',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: const BoxDecoration(
                            color: Color(0x69BDBDBD),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Align(
                            alignment: const Alignment(0, 0),
                            child: AutoSizeText(
                              code,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: const BoxDecoration(
                            color: Color(0x69BDBDBD),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () async {
                                try {
                                  // await ClipboardManager.copyToClipBoard(
                                  //     code);
                                  await FlutterClipboard.copy(code);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(copySuccessSnakbar);
                                } catch (error) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(failureSnackbar);
                                }
                              },
                              icon: const Icon(
                                Icons.copy_outlined,
                                color: Color(0xFF000000),
                                size: 25,
                              ),
                              iconSize: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: _isLoading
                        ? const CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white)
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: CustomButton(
                              text: "Share",
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                var referalLink =
                                    await dynamicLink.createReferralLink(code);
                                Share.share(
                                    'Inviting you to join Grooks app with me. On Grooks we can make opinions using real money on various topics like Sports, Weather, Politics, BigBoss, Kabaddi, Finance, News and win if our opinions are right. Join me on Grooks and trade on your opinions. Use the link to claim your free trades worth ₹250. Download Grooks here: $referalLink');
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => setState(() => _isLoading = false),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
