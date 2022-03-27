import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/closed_questions_screen.dart';
import 'package:grooks_dev/screens/user/open_questions_screen.dart';

class QuestionsScreen extends StatefulWidget {
  final Users user;
  final String subcategoryId;
  final String subcategoryName;
  const QuestionsScreen({
    Key? key,
    required this.subcategoryId,
    required this.user,
    required this.subcategoryName,
  }) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _repository = FirebaseRepository();
    _questions = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: AutoSizeText(
          widget.subcategoryName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.895,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      initialIndex: 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: TabBar(
                              labelColor: const Color(0xFF130F26),
                              indicator: BoxDecoration(
                                color: const Color(0x402DEB51),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              tabs: const [
                                Tab(
                                  text: 'LIVE',
                                ),
                                Tab(
                                  text: 'CLOSED',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                OpenQuestionsDetailScreen(
                                  user: widget.user,
                                  subcategoryId: widget.subcategoryId,
                                ),
                                ClosedQuestionsDetailScreen(
                                  user: widget.user,
                                  subcategoryId: widget.subcategoryId,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
