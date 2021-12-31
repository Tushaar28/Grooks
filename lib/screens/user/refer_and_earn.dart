import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/dynamic_link.dart';
import 'package:share_plus/share_plus.dart';

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
  DynamicLinkApi dynamicLink = new DynamicLinkApi();
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
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    showSpinner = false;
    repository = FirebaseRepository();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 1,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/refer.png',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const AutoSizeText(
                    'Refer your friends and earn 500 coins on every successful referral',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.08,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const Align(
                    alignment: Alignment(0, 0),
                    child: AutoSizeText(
                      'Your Referral code',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: const BoxDecoration(
                        color: Color(0x69BDBDBD),
                      ),
                      child: Align(
                        alignment: const Alignment(0, 0),
                        child: AutoSizeText(
                          widget.user.referralCode,
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
                        color: Color(0xFFEEEEEE),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          try {
                            // await ClipboardManager.copyToClipBoard(
                            //     widget.user.referralCode);
                            await FlutterClipboard.copy(
                                widget.user.referralCode);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(copySuccessSnakbar);
                          } catch (error) {
                            print("ERROR = ${error.toString()}");
                            ScaffoldMessenger.of(context)
                                .showSnackBar(failureSnackbar);
                          }
                        },
                        icon: const Icon(
                          Icons.content_copy,
                          color: Color(0xDD9E9E9E),
                          size: 30,
                        ),
                        iconSize: 30,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: showSpinner
                    ? const CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white)
                    : TextButton(
                        onPressed: () async {
                          setState(() => showSpinner = true);
                          var referalLink = await dynamicLink
                              .createReferralLink(widget.user.referralCode);
                          Share.share(referalLink);
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () => setState(() => showSpinner = false),
                          );
                        },
                        child: const Text("Share"),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: TextButton(
                  child: AutoSizeText(
                    'View Referrals',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
