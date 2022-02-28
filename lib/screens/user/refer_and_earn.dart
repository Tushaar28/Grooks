import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/dynamic_link.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
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
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    print("CODE = " + widget.user.referralCode);
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
                    child: showSpinner
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
                                setState(() => showSpinner = true);
                                var referalLink =
                                    await dynamicLink.createReferralLink(
                                        widget.user.referralCode);
                                Share.share(referalLink);
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => setState(() => showSpinner = false),
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
