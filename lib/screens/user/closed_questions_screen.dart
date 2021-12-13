import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/open_questions_widget.dart';
import 'package:grooks_dev/screens/user/question_detail_screen.dart';
import 'package:grooks_dev/widgets/question_card.dart';
import 'package:page_transition/page_transition.dart';

class ClosedQuestionsDetailScreen extends StatefulWidget {
  final Users user;
  final String subcategoryId;
  const ClosedQuestionsDetailScreen({
    Key? key,
    required this.user,
    required this.subcategoryId,
  }) : super(key: key);

  @override
  _ClosedQuestionsDetailScreenState createState() =>
      _ClosedQuestionsDetailScreenState();
}

class _ClosedQuestionsDetailScreenState
    extends State<ClosedQuestionsDetailScreen>
    with AutomaticKeepAliveClientMixin {
  late List<Question> _questions;
  late final FirebaseRepository _repository;
  late bool? _isActive;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    _questions = [];
    _repository = FirebaseRepository();
    getUserActiveStatus();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    _isActive = data;
  }

  Future<List<Question>> getClosedQuestions() async {
    _questions = await _repository.getClosedQuestions(
      subcategoryId: widget.subcategoryId,
    );
    return _questions;
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
      future: getClosedQuestions(),
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
              "No closed questions",
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
                      onTap: () => Navigator.of(context).push(
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
                      ),
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
