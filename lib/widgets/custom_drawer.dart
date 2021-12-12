import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/auth.dart';
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
                        builder: (context) => const Auth(),
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
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.08,
                      child: user.image != null && user.image!.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              placeholder: "assets/images/user.png",
                              image: user.image!,
                            )
                          : Image.asset("assets/images/user.png"),
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
                          user.mobile.substring(3),
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
                            onPressed: () {},
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                // ListTile(
                //   leading: Image.asset("assets/images/wallet.png"),
                //   title: const AutoSizeText(
                //     'Help your friends',
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   trailing: const Icon(
                //     Icons.arrow_forward_ios,
                //     color: Colors.black87,
                //   ),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(
                //       PageTransition(
                //         child: CoinsTransferWidget(user: this.user),
                //         type: PageTransitionType.bottomToTop,
                //         duration: const Duration(milliseconds: 300),
                //         reverseDuration: const Duration(milliseconds: 300),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Image.asset("assets/images/share.png"),
                //   title: const AutoSizeText(
                //     'Share with friends',
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   trailing: const Icon(
                //     Icons.arrow_forward_ios,
                //     color: Colors.black87,
                //   ),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(
                //       PageTransition(
                //         child: ReferralWidget(user: this.user),
                //         type: PageTransitionType.bottomToTop,
                //         duration: Duration(milliseconds: 300),
                //         reverseDuration: Duration(milliseconds: 300),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Image.asset("assets/images/how_to_trade.png"),
                //   title: AutoSizeText(
                //     'How to Trade',
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   trailing: Icon(
                //     Icons.arrow_forward_ios,
                //     color: Colors.black87,
                //   ),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(
                //       PageTransition(
                //         child: FeedbackWidget(user: this.user),
                //         type: PageTransitionType.bottomToTop,
                //         duration: Duration(milliseconds: 300),
                //         reverseDuration: Duration(milliseconds: 300),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Image.asset("assets/images/settings.png"),
                //   title: AutoSizeText(
                //     'Settings',
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   trailing: Icon(
                //     Icons.arrow_forward_ios,
                //     color: Colors.black87,
                //   ),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(
                //       PageTransition(
                //         child: FeedbackWidget(user: this.user),
                //         type: PageTransitionType.bottomToTop,
                //         duration: Duration(milliseconds: 300),
                //         reverseDuration: Duration(milliseconds: 300),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Image.asset("assets/images/chat.png"),
                //   title: const AutoSizeText(
                //     'Report an issue',
                //     style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                //   trailing: const Icon(
                //     Icons.arrow_forward_ios,
                //     color: Colors.black87,
                //   ),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     Navigator.of(context).push(
                //       PageTransition(
                //         child: FeedbackWidget(user: this.user),
                //         type: PageTransitionType.bottomToTop,
                //         duration: Duration(milliseconds: 300),
                //         reverseDuration: Duration(milliseconds: 300),
                //       ),
                //     );
                //   },
                // ),
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