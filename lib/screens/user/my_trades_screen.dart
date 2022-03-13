import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/screens/user/question_detail_screen.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';

import 'trade_success_screen.dart';

class MyTradesScreen extends StatefulWidget {
  final Users user;
  final Question question;
  const MyTradesScreen({
    Key? key,
    required this.question,
    required this.user,
  }) : super(key: key);

  @override
  _MyTradesScreenState createState() => _MyTradesScreenState();
}

class _MyTradesScreenState extends State<MyTradesScreen>
    with AutomaticKeepAliveClientMixin {
  late List<Trade> _trades;
  late final FirebaseRepository _repository;
  late bool _isLoading;
  late bool? _isActive;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    _trades = [];
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _isLoading = false;
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<void> refresh() async {
    setState(() {});
  }

  String getTradeStatus(Trade trade) {
    if (trade.status == Status.ACTIVE_PAIRED) return 'FILLED';
    if (trade.status == Status.ACTIVE_UNPAIRED) return 'CANCEL';
    if (trade.status == Status.AUTO_CANCEL ||
        trade.status == Status.CANCELLED_BY_USER) return 'CANCELLED';
    if (trade.status == Status.LOST) return 'LOST';
    if (trade.status == Status.WON) return 'WON';
    return '';
  }

  Future<void> cancelTrade({
    required Trade trade,
    required BuildContext context,
  }) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Alert'),
            content: const Text('Are you sure you want to cancel your trade?'),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : SwipeButton(
                        text: 'Slide to cancel',
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: 300,
                        color: Colors.red,
                        backgroundColorEnd: Colors.redAccent[100],
                        onSwipeCallback: () async {
                          try {
                            setState(() => _isLoading = true);
                            bool isQuestionActive =
                                await _repository.getQuestionActiveStatus(
                                    questionId: trade.questionId);
                            if (isQuestionActive == false) {
                              throw 'An error occured';
                            }
                            await _repository.cancelTrade(
                              trade: trade,
                              userId: widget.user.id,
                            );
                            setState(() => _isLoading = false);
                            Navigator.maybeOf(context)!.pop();
                          } catch (error) {
                            rethrow;
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Trade>> getTradesForQuestionForUser() async {
    _trades = await _repository.getTradesForQuestionForUser(
      userId: widget.user.id,
      questionId: widget.question.id,
    );
    return _trades;
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
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
      });
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder<List<Trade>>(
        future: getTradesForQuestionForUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            );
          }

          if (_trades.isEmpty) {
            return const Center(
              child: Text('No trades'),
            );
          }
          return ListView.separated(
            itemCount: _trades.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.05,
                  10,
                  MediaQuery.of(context).size.width * 0.05,
                  0,
                ),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          _trades[index].response
                              ? 'YES @ ${_trades[index].coins}'
                              : 'NO @ ${_trades[index].coins}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_trades[index].status != Status.ACTIVE_UNPAIRED)
                        Expanded(
                          child: Center(
                            child: Text(
                              getTradeStatus(_trades[index]),
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      widget.question.answer != null
                          ? const Expanded(
                              child: SizedBox(
                                width: 0,
                              ),
                            )
                          : _trades[index].status == Status.AUTO_CANCEL ||
                                  _trades[index].status ==
                                      Status.CANCELLED_BY_USER ||
                                  _trades[index].status ==
                                      Status.ACTIVE_PAIRED ||
                                  _trades[index].status == Status.WON ||
                                  _trades[index].status == Status.LOST
                              ? const Expanded(
                                  child: SizedBox(
                                    width: 0,
                                  ),
                                )
                              : Expanded(
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () async {
                                        try {
                                          await cancelTrade(
                                              trade: _trades[index],
                                              context: context);
                                          Navigator.maybeOf(context)!
                                              .pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TradeSuccessScreen(
                                                user: widget.user,
                                              ),
                                            ),
                                          );
                                        } catch (error) {
                                          setState(() => _isLoading = false);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text("An error occured"),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          await Future.delayed(
                                            const Duration(seconds: 2),
                                            () => Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NavbarScreen(
                                                        user: widget.user),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Cancel'),
                                      style: TextButton.styleFrom(
                                        primary: const Color(0xFFC31D1D),
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
        },
      ),
    );
  }
}
