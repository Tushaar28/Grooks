import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:grooks_dev/widgets/custom_carousel.dart';
import 'package:page_transition/page_transition.dart';

class OnboardingScreen extends StatefulWidget {
  final Users user;
  const OnboardingScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> pages = [
    {
      "image": "onboarding1.svg",
      "title": "Page 1",
      "desc": "Description for page 1"
    },
    {
      "image": "onboarding2.svg",
      "title": "Page 2",
      "desc": "Description for page 2"
    },
    {
      "image": "onboarding3.svg",
      "title": "Page 3",
      "desc": "Description for page 3"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: CustomCarousel(pages: pages),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: CustomButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      PageTransition(
                        child: NavbarScreen(
                          user: widget.user,
                        ),
                        type: PageTransitionType.bottomToTop,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                    text: "Get Started",
                    elevation: 80,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
