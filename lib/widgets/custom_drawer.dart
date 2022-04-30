import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/coins_transfer_screen.dart';
import 'package:grooks_dev/screens/user/edit_profile_screen.dart';
import 'package:grooks_dev/screens/user/feedback_screen.dart';
import 'package:grooks_dev/screens/user/refer_and_earn.dart';
import 'package:grooks_dev/screens/user/referral_contest_screen.dart';
import 'package:grooks_dev/screens/user/store_screen.dart';
import 'package:grooks_dev/screens/user/withdrawl_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  final BuildContext context;
  final Users user;
  CustomDrawer({
    Key? key,
    required this.context,
    required this.user,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final logoutFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  late final FirebaseRepository _repository;
  late Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
  }

  void logout({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                  child: const AutoSizeText(
                    "Logout",
                    minFontSize: 18,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                  child: const AutoSizeText(
                    "Are you sure you want to logout?",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    height: 0,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  width: 300,
                  child: SwipeButton(
                    text: 'Slide to logout',
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: 300,
                    color: Colors.red,
                    backgroundColorEnd: Colors.redAccent[100],
                    onSwipeCallback: () async {
                      try {
                        _mixpanel.identify(widget.user.id);
                        _mixpanel.track(
                          "logout",
                          properties: {
                            "userId": widget.user.id,
                          },
                        );
                        await _repository.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false);
                      } catch (error) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(logoutFailureSnackbar);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: const BoxDecoration(
              color: Color(0xFF1C3857),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: DrawerHeader(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).size.height * 0.02,
                16,
                MediaQuery.of(context).size.height * 0.03,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      5,
                      MediaQuery.of(context).size.height * 0.01,
                      0,
                      MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: widget.user.image != null &&
                              widget.user.image!.isNotEmpty
                          ? ClipOval(
                              child: FadeInImage.assetNetwork(
                                placeholder: "assets/images/user.png",
                                image: widget.user.image!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              "assets/images/user.png",
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  AutoSizeText(
                    widget.user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          widget.user.mobile?.substring(3) ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(user: widget.user),
                                ),
                              );
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
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            color: Colors.transparent,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/how_to_trade_drawer.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'How to trade',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () async {
                      String? link = await _repository.getVideoLink;
                      if (link == null || link.isEmpty) {
                        return;
                      }
                      Navigator.of(context).pop();
                      await launch(link);
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/refer_drawer.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Refer and Earn',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: ReferralWidget(user: widget.user),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/refer_drawer.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Referral Contest',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: ReferralContestScreen(userId: widget.user.id),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/WithdrawIcon.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Withdraw',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: WithdrawlScreen(
                            userId: widget.user.id,
                          ),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/support_drawer.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Support',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: FeedbackScreen(user: widget.user),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/StoreIcon.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Store',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: StoreScreen(user: widget.user),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/help_your_friends_drawer.png",
                      height: 40,
                    ),
                    title: const AutoSizeText(
                      'Help your friends',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        PageTransition(
                          child: CoinsTransferScreen(user: widget.user),
                          type: PageTransitionType.bottomToTop,
                          duration: const Duration(milliseconds: 300),
                          reverseDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          const Divider(
            color: Colors.white,
          ),
          Container(
            color: Colors.transparent,
            child: ListTile(
              title: const Align(
                alignment: Alignment.bottomCenter,
                child: AutoSizeText(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () async {
                _mixpanel = await MixpanelManager.init();
                Navigator.of(context).pop();
                logout(context: context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
