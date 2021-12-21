import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/screens/user/questions_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.155,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
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
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: Colors.transparent,
            elevation: 5,
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
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.1,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.subcategory.image != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: "assets/images/user.png",
                                  image: widget.subcategory.image!,
                                )
                              : Image.asset("assets/images/user.png"),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
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
                                  child: AutoSizeText(
                                    widget.subcategory.name,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: AutoSizeText(
                                  'Related to all categories',
                                  style: GoogleFonts.getFont(
                                    'Roboto',
                                    color: Colors.grey,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
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
                          width: MediaQuery.of(context).size.width * 0.2,
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
