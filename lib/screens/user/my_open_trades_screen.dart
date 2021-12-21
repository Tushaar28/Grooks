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

class MyOpenTradesScreen extends StatefulWidget {
  final Users user;
  const MyOpenTradesScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _MyOpenTradesScreenState createState() => _MyOpenTradesScreenState();
}

class _MyOpenTradesScreenState extends State<MyOpenTradesScreen>
    with AutomaticKeepAliveClientMixin {
  late final FirebaseRepository _repository;
  late List<Trade> _openTrades;
  late bool? _isActive;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _openTrades = [];
    _isActive = null;
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  bool get wantKeepAlive => false;

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<List<Trade>> getOpenTradesForUser() async {
    try {
      _openTrades = await _repository.getOpenTradesForUser(
        userId: widget.user.id,
      );
      return _openTrades;
    } catch (error) {
      rethrow;
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
      rethrow;
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
        future: getOpenTradesForUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            );
          }
          if (_openTrades.isEmpty) {
            return const Center(
              child: AutoSizeText(
                "No open trades",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: _openTrades.length,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<Question>(
                future: getQuestionDetails(
                    questionId: _openTrades[index].questionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load details. Please try again'),
                    );
                  } else {
                    Question question = snapshot.data!;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: InkWell(
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
                              reverseDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
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
                                      const EdgeInsets.fromLTRB(10, 0, 10, 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 5, 0),
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
                                            5, 0, 5, 0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          child: Align(
                                            alignment: const Alignment(0, 0),
                                            child: AutoSizeText(
                                              question.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                        const TextSpan(text: 'Your trade    '),
                                        TextSpan(
                                          text: _openTrades[index].response
                                              ? 'YES'
                                              : 'NO',
                                          style: TextStyle(
                                            color: _openTrades[index].response
                                                ? Theme.of(context).primaryColor
                                                : Colors.red,
                                            fontSize: 18,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' @${_openTrades[index].coins}',
                                          style: TextStyle(
                                            color: _openTrades[index].response
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
