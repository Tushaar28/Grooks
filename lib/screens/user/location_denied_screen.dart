import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grooks_dev/services/location.dart';

class LocationDeniedScreen extends StatelessWidget {
  LocationDeniedScreen({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/splash_bg.png",
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Center(
                    child: Image.asset("assets/images/splash_fg.png"),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(50),
                    ),
                    image: DecorationImage(
                      image: AssetImage("assets/images/card_bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: SvgPicture.asset(
                          "assets/images/location_denied.svg",
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: const Center(
                          child: AutoSizeText(
                            "Location Access Denied !",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: TextButton(
                          child: const AutoSizeText(
                            "Open app settings",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            var isOpened = await Geolocator.openAppSettings();
                            if (isOpened) {
                              await Future.delayed(
                                const Duration(seconds: 3),
                                () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const Location(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
