import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/question_detail_screen.dart';
import 'package:page_transition/page_transition.dart';

class MyClosedTradesScreen extends StatefulWidget {
  final Users user;
  const MyClosedTradesScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _MyClosedTradesScreenState createState() => _MyClosedTradesScreenState();
}

class _MyClosedTradesScreenState extends State<MyClosedTradesScreen>
    with AutomaticKeepAliveClientMixin {
  late final FirebaseRepository _repository;
  late List<Trade> _closedTrades;
  late bool? _isActive;

  @override
  bool get wantKeepAlive => false;

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _isActive = null;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _closedTrades = [];
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<List<Trade>> getClosedTradesForUser() async {
    try {
      _closedTrades = await _repository.getClosedTradesForUser(
        userId: widget.user.id,
      );
      return _closedTrades;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<Question> getQuestionDetails({
    required String questionId,
  }) async {
    try {
      Question question =
          await _repository.getQuestionDetails(questionId: questionId);
      return question;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<String> getSubcategoryNameForQuestion({
    required String questionId,
  }) async {
    try {
      String name = await _repository.getSubcategoryNameForQuestion(
          questionId: questionId);
      return name;
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.blue,
        ),
      );
    }
    if (_isActive == false) {
      _repository.signOut();
      SchedulerBinding.instance!.addPostFrameCallback(
        (_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<List<Trade>>(
        future: getClosedTradesForUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            );
          } else if (_closedTrades.isEmpty) {
            return const Center(
              child: AutoSizeText(
                "No closed trades",
              ),
            );
          }
          return ListView.builder(
            itemCount: _closedTrades.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<Question>(
                future: getQuestionDetails(
                    questionId: _closedTrades[index].questionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load details. Please try again'),
                    );
                  } else {
                    Question question = snapshot.data!;
                    return InkWell(
                      onTap: () async {
                        Navigator.of(context).push(
                          PageTransition(
                            child: QuestionDetailScreen(
                              questionId: question.id,
                              questionName: question.name,
                              user: widget.user,
                            ),
                            type: PageTransitionType.bottomToTop,
                            duration: const Duration(milliseconds: 300),
                            reverseDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FutureBuilder<String>(
                                  future: getSubcategoryNameForQuestion(
                                      questionId: question.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return const SizedBox(
                                        height: 0,
                                        width: 0,
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 5, 10, 10),
                                      child: Text(
                                        snapshot.data!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.13,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            child: question.image != null
                                                ? FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/images/user.png",
                                                    image: question.image!)
                                                : Image.asset(
                                                    "assets/images/user.png"),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: Align(
                                          alignment: const Alignment(0, 0),
                                          child: Text(
                                            question.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text: 'Event closed at    '),
                                        TextSpan(
                                          text: question.answer! ? 'YES' : 'NO',
                                          style: TextStyle(
                                            color: _closedTrades[index].response
                                                ? Theme.of(context).primaryColor
                                                : Colors.red,
                                            fontSize: 18,
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
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
