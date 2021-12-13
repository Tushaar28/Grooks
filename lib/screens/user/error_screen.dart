import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';

class ErrorScreen extends StatelessWidget {
  final Users user;
  const ErrorScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset("assets/images/error.svg"),
                ),
              ),
              TextButton(
                child: const Text("Go to Home page"),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => NavbarScreen(user: user),
                    ),
                    (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
