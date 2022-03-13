import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/question_detail_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/question_card.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:page_transition/page_transition.dart';

class OpenQuestionsDetailScreen extends StatefulWidget {
  final Users user;
  final String subcategoryId;
  const OpenQuestionsDetailScreen({
    Key? key,
    required this.user,
    required this.subcategoryId,
  }) : super(key: key);

  @override
  _OpenQuestionsDetailScreenState createState() =>
      _OpenQuestionsDetailScreenState();
}

class _OpenQuestionsDetailScreenState extends State<OpenQuestionsDetailScreen>
    with AutomaticKeepAliveClientMixin {
  late List<Question> _questions;
  late final FirebaseRepository _repository;
  late bool? _isActive;
  late final Mixpanel _mixpanel;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isActive = true;
    _questions = [];
    _repository = FirebaseRepository();
    getUserActiveStatus();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    _isActive = data;
  }

  Future<List<Question>> getOpenQuestions() async {
    _questions =
        await _repository.getOpenQuestions(subcategoryId: widget.subcategoryId);
    return _questions;
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Future<int> getYesTradePercentage(Question question) async {
    int openTrades = question.openTradesCount ?? 0;
    int pairedTrades = question.pairedTradesCount ?? 0;
    if (openTrades + pairedTrades == 0) return 50;
    int percentage =
        ((question.yesTrades!.length / (openTrades + pairedTrades * 2)) * 100)
            .round();
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    if (_isActive == false) {
      _repository.signOut();
      SchedulerBinding.instance!.addPostFrameCallback(
        (timeStamp) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false);
        },
      );
    }
    return FutureBuilder(
      future: getOpenQuestions(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.white,
            ),
          );
        }
        if (_questions.isEmpty) {
          return const Center(
            child: Text(
              "No active questions",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            color: Colors.transparent,
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.02,
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        _mixpanel.identify(widget.user.id);
                        _mixpanel.track(
                          "question_clicked",
                          properties: {
                            "questionId": _questions[index].id,
                            "questionName": _questions[index].name,
                          },
                        );
                        Navigator.of(context).push(
                          PageTransition(
                            child: QuestionDetailScreen(
                              user: widget.user,
                              questionId: _questions[index].id,
                              questionName: _questions[index].name,
                            ),
                            type: PageTransitionType.bottomToTop,
                            duration: const Duration(milliseconds: 300),
                            reverseDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: QuestionCard(
                        question: _questions[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
