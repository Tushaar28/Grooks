import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
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
  late int _index;
  final List<Map<String, String>> _pages = [
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
  void initState() {
    super.initState();
    _index = 0;
  }

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
              child: PageView.builder(
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.09,
                    MediaQuery.of(context).size.height * 0.01,
                    0,
                    0,
                  ),
                  child: SvgPicture.asset(
                      "assets/images/${_pages[_index]["image"]}"),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: CustomButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        setState(() => ++_index);
                      } else {
                        Navigator.of(context).pushReplacement(
                          PageTransition(
                            child: NavbarScreen(
                              user: widget.user,
                            ),
                            type: PageTransitionType.bottomToTop,
                            duration: const Duration(milliseconds: 300),
                          ),
                        );
                      }
                    },
                    text: _index < _pages.length - 1 ? "Next" : "Get Started",
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
