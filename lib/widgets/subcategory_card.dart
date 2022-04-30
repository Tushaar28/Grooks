import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/questions_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:page_transition/page_transition.dart';

class CustomSubcategoryCard extends StatefulWidget {
  final Category subcategory;
  final Users user;
  const CustomSubcategoryCard({
    Key? key,
    required this.subcategory,
    required this.user,
  }) : super(key: key);

  @override
  _CustomSubcategoryCardState createState() => _CustomSubcategoryCardState();
}

class _CustomSubcategoryCardState extends State<CustomSubcategoryCard> {
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.16,
      child: InkWell(
        onTap: () {
          _mixpanel.identify(widget.user.id);
          _mixpanel.track(
            "subcategory_clicked",
            properties: {
              "subcategoryId": widget.subcategory.id,
              "subcategoryName": widget.subcategory.name,
            },
          );
          Navigator.of(context).push(
            PageTransition(
              child: QuestionsScreen(
                subcategoryId: widget.subcategory.id,
                subcategoryName: widget.subcategory.name,
                user: widget.user,
              ),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(
                milliseconds: 300,
              ),
              reverseDuration: const Duration(
                milliseconds: 300,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: Colors.transparent,
            elevation: 5,
            shadowColor: const Color(0x1A1C3857),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/category_bg.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    10,
                    0,
                    10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.subcategory.image == null ||
                                  widget.subcategory.image!.isEmpty
                              ? Image.asset("assets/images/fallback.png")
                              : FadeInImage.assetNetwork(
                                  placeholder: "assets/images/fallback.png",
                                  image: widget.subcategory.image ??
                                      "assets/images/fallback.png"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.height * 0.11,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.06,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                0,
                                10,
                                0,
                                0,
                              ),
                              child: Center(
                                child: AutoSizeText(
                                  widget.subcategory.name,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          10,
                          0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: AutoSizeText(
                                  '${widget.subcategory.openEvents} event(s) live',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF269E3D),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: AutoSizeText(
                                  '${widget.subcategory.closedEvents} event(s) cosed',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFFEB6821),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
