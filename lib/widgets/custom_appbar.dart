import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grooks_dev/constants/constants.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/activity_screen.dart';
import 'package:page_transition/page_transition.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String userId;
  const CustomAppbar({
    Key? key,
    required this.context,
    required this.scaffoldKey,
    required this.userId,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(MediaQuery.of(context).size.height * 0.04);

  @override
  _CustomAppbarState createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  late final FirebaseRepository _repository;
  late int bonusCoins, redeemableCoins;
  late bool _isDataLoaded;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    bonusCoins = redeemableCoins = 0;
    _isDataLoaded = false;
    getUserDetails();
  }

  Future<int> getUserDetails() async {
    try {
      bonusCoins = await _repository.getUserBonusCoins(userId: widget.userId);
      redeemableCoins =
          await _repository.getUserRedeemableCoins(userId: widget.userId);
      setState(() => _isDataLoaded = true);
      return bonusCoins + redeemableCoins;
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        child: Image.asset("assets/images/drawer.png"),
        onTap: () => widget.scaffoldKey.currentState!.openDrawer(),
      ),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: MediaQuery.of(context).size.height * 0.03,
        width: MediaQuery.of(context).size.width * 0.25,
        child: SvgPicture.asset(
          "assets/images/appbar.svg",
          color: const Color(0xFF1C3857),
        ),
      ),
      actions: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            PageTransition(
              child: ActivityScreen(userId: widget.userId),
              type: PageTransitionType.bottomToTop,
              duration: const Duration(
                milliseconds: 300,
              ),
              reverseDuration: const Duration(
                milliseconds: 300,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                  child: AutoSizeText(
                    '${bonusCoins + redeemableCoins}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset("assets/images/coins.png"),
              ],
            ),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
}
