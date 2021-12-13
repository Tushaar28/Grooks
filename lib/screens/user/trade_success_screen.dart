import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';

// ignore: must_be_immutable
class TradeSuccessScreen extends StatelessWidget {
  final Users user;
  late Timer timer;
  TradeSuccessScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    timer = Timer(
      const Duration(milliseconds: 3000),
      () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => NavbarScreen(user: user),
          ),
          (route) => false),
    );
    return Container(
      color: const Color(0xFFFFFFFF),
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Expanded(
            child: Image.asset("assets/images/trade.png"),
          ),
        ],
      ),
    );
  }
}
