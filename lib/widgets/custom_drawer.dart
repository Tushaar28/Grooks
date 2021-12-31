import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/coins_transfer_screen.dart';
import 'package:grooks_dev/screens/user/edit_profile_screen.dart';
import 'package:grooks_dev/screens/user/feedback_screen.dart';
import 'package:grooks_dev/screens/user/how_to_trade_screen.dart';
import 'package:grooks_dev/screens/user/refer_and_earn.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:page_transition/page_transition.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext context;
  final Users user;
  CustomDrawer({
    Key? key,
    required this.context,
    required this.user,
  }) : super(key: key);

  final logoutFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured.'),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );
  final FirebaseRepository _repository = FirebaseRepository();

  void logout({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            SwipeButton(
              text: 'Slide to logout',
              height: MediaQuery.of(context).size.height * 0.06,
              width: 300,
              color: Colors.red,
              backgroundColorEnd: Colors.redAccent[100],
              onSwipeCallback: () async {
                try {
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
          ],
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
            height: MediaQuery.of(context).size.height * 0.275,
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
                      child: user.image != null && user.image!.isNotEmpty
                          ? ClipOval(
                              child: FadeInImage.assetNetwork(
                                placeholder: "assets/images/user.png",
                                image: user.image!,
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
                  Text(
                    user.name,
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
                        Text(
                          user.mobile?.substring(3) ?? "",
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
                                      EditProfileScreen(user: user),
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
            color: Colors.transparent,
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset("assets/images/how_to_trade.png"),
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
                        child: ReferralWidget(user: user),
                        type: PageTransitionType.bottomToTop,
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset("assets/images/wallet.png"),
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
                        child: CoinsTransferScreen(user: user),
                        type: PageTransitionType.bottomToTop,
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset("assets/images/chat.png"),
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
                        child: FeedbackScreen(user: user),
                        type: PageTransitionType.bottomToTop,
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
              ],
            ),
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
              onTap: () {
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
