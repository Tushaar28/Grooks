import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:grooks_dev/widgets/custom_carousel.dart';

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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomCarousel(pages: pages),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                child: CustomButton(
                  onPressed: () {},
                  text: "Get Started",
                  elevation: 80,
                  color: Colors.blueGrey,
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
    );
  }
}
