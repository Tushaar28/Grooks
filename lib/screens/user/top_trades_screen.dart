import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/trade_success_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class TopTradesScreen extends StatefulWidget {
  final Users user;
  final Question question;
  const TopTradesScreen({
    Key? key,
    required this.question,
    required this.user,
  }) : super(key: key);

  @override
  _TopTradesScreenState createState() => _TopTradesScreenState();
}

class _TopTradesScreenState extends State<TopTradesScreen>
    with AutomaticKeepAliveClientMixin {
  late Map<String, dynamic> _trades;
  late List<String> _tradesKeys;
  late final FirebaseRepository _repository;
  late bool _tradePlaced, _tradeError, _isLoading;
  late bool? _isActive;
  late bool _dataLoaded;
  late bool? _isQuestionActive;
  late final Mixpanel _mixpanel;

  final viewSuccessSnackbar = const SnackBar(
    content: AutoSizeText("Your view has been placed"),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  );
  final tradeFailureSnackbar = const SnackBar(
    content: AutoSizeText("An error occured"),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isActive = true;
    _dataLoaded = false;
    _isQuestionActive = true;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    getQuestionActiveStatus();
    _trades = <String, dynamic>{};
    _tradesKeys = [];
    getTopTrades();
    _tradeError = _tradePlaced = _isLoading = false;
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("top_trades_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Future<void> getUserActiveStatus() async {
    _isActive = await _repository.getUserActiveStatus(userId: widget.user.id);
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Future<void> getQuestionActiveStatus() async {
    try {
      bool status = await _repository.getQuestionActiveStatus(
          questionId: widget.question.id);
      setState(() => _isQuestionActive = status);
    } catch (error) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getTopTrades() async {
    QuerySnapshot data = await _repository.getTopTrades(
      userId: widget.user.id,
      questionId: widget.question.id,
    );

    for (var element in data.docs) {
      if (element.exists) {
        String key = element.get('coins').toString();
        if (element.get('response') == false) key = '-' + key;
        if (_trades.containsKey(key)) {
          List<Trade> current = _trades[key];
          int index =
              current.indexWhere((value) => value.id == element.get('id'));
          if (index == -1) {
            current.add(Trade.fromMap(element.data() as Map<String, dynamic>));
          } else {
            current[index] =
                Trade.fromMap(element.data() as Map<String, dynamic>);
          }
          _trades[key] = current;
        } else {
          List<Trade> trades = [];
          trades.add(Trade.fromMap(element.data() as Map<String, dynamic>));
          _trades[key] = trades;
        }
      }
    }
    _tradesKeys = _trades.keys.toList();
    setState(() => _dataLoaded = true);
    return data;
  }

  Future<bool> pairTradeConfirmation({
    required BuildContext context,
    required Trade trade,
  }) async {
    bool answer = await showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const AutoSizeText('Alert'),
            content:
                const AutoSizeText('Are you sure you want to pair this trade?'),
            actions: [
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : SwipeButton(
                      text: 'Slide to confirm',
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: 300,
                      backgroundColorEnd: Colors.blueAccent[100],
                      onSwipeCallback: () async {
                        try {
                          setState(() => _isLoading = true);
                          await pairTrade(trade: trade);
                          _mixpanel.identify(widget.user.id);
                          _mixpanel.getPeople().increment("paired_trades", 1);
                          _mixpanel.getPeople().increment("total_trades", 1);
                          _mixpanel.track(
                            "trade_pair_success",
                            properties: {
                              "userId": widget.user.id,
                              "questionId": widget.question.id,
                              "questionName": widget.question.name,
                            },
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TradeSuccessScreen(user: widget.user),
                            ),
                            (r) => false,
                          );
                        } catch (error) {
                          _mixpanel.identify(widget.user.id);
                          _mixpanel
                              .getPeople()
                              .increment("paired_trades_failed", 1);
                          _mixpanel
                              .getPeople()
                              .increment("total_trades_failed", 1);
                          _mixpanel.track(
                            "trade_pair_failed",
                            properties: {
                              "userId": widget.user.id,
                              "questionId": widget.question.id,
                              "questionName": widget.question.name,
                            },
                          );
                          Navigator.of(context).pop();
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          if (error.toString() == "Insufficient coins") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: AutoSizeText("Insufficient coins"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: AutoSizeText("An error occured"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          rethrow;
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                    ),
            ],
          );
        },
      ),
    );
    return answer;
  }

  Future<void> pairTrade({
    required Trade trade,
  }) async {
    try {
      bool isQuestionActive = await _repository.getQuestionActiveStatus(
          questionId: trade.questionId);
      if (isQuestionActive == false) {
        throw 'An error occured';
      }
      await _repository.pairTrade(
        firstTrade: trade,
        userId: widget.user.id,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getUserNameFromUserId({
    required String userId,
  }) async {
    try {
      return await _repository.getUserNameFromUserId(userId: userId);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.answer != null) {
      return const Center(
        child: AutoSizeText("No trades"),
      );
    }
    if (_isActive == null || _isQuestionActive == null) {
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
    if (_isQuestionActive == false) {
      return const Center(
        child: AutoSizeText(
          "Question is closed",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );
    }
    if (_dataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    return Stack(
      children: [
        ListView.separated(
          itemCount: _tradesKeys.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return FutureBuilder<String>(
              future: getUserNameFromUserId(
                  userId: _trades[_tradesKeys[index]].first.userId),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                    ),
                  );
                }
                return Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                                child: _trades[_tradesKeys[index]].length > 1
                                    ? AutoSizeText(
                                        '${(snapshot.data!.split(' ').first)} + ${_trades[_tradesKeys[index]].length - 1} others says',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      )
                                    : AutoSizeText(
                                        '${snapshot.data} says',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: MediaQuery.of(context).size.height * 0.03,
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: _trades[_tradesKeys[index]]
                                            .first
                                            .response
                                        ? const AutoSizeText(
                                            'YES',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                            ),
                                          )
                                        : const AutoSizeText(
                                            'NO',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: AutoSizeText(
                                      '@ ${_trades[_tradesKeys[index]].first.coins}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.05,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await pairTradeConfirmation(
                                  context: context,
                                  trade: _trades[_tradesKeys[index]].first);
                            } catch (error) {}
                          },
                          child: AutoSizeText(
                            _trades[_tradesKeys[index]].first.response
                                ? 'SAY NO @ ${100 - _trades[_tradesKeys[index]].first.coins}'
                                : 'SAY YES @ ${100 - _trades[_tradesKeys[index]].first.coins}',
                            style: TextStyle(
                              color: _trades[_tradesKeys[index]].first.response
                                  ? const Color(0xFFC31D1D)
                                  : Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            side: BorderSide(
                              color: _trades[_tradesKeys[index]].first.response
                                  ? const Color(0xFFC31D1D)
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
