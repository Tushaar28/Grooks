import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:intl/intl.dart';

class TradesActivityScreen extends StatefulWidget {
  final String userId;
  final BoxConstraints constraints;
  const TradesActivityScreen({
    Key? key,
    required this.userId,
    required this.constraints,
  }) : super(key: key);

  @override
  _TradesActivityScreenState createState() => _TradesActivityScreenState();
}

class _TradesActivityScreenState extends State<TradesActivityScreen> {
  late final FirebaseRepository _repository;
  late List<Map<String, dynamic>> _trades;
  late DateTime? _lastDate;
  late String? _lastId;
  late final ScrollController _scrollController;
  late bool _isLoading, _allLoaded, _isExpanded, _isActive;
  late int? _prevIndex, _pageSize;
  late Future<List<Map<String, dynamic>>> _initialData;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _trades = [];
    _pageSize = 20;
    _isExpanded = _allLoaded = _isLoading = false;
    _isActive = true;
    _lastDate = null;
    _lastId = null;
    _initialData = getUserTradeActivities();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        getUserTradeActivities();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
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

  String getTradeStatus(Trade trade) {
    switch (trade.status) {
      case Status.WON:
        return "${trade.coinsWon!.abs()} coins won";
      case Status.LOST:
        return "${trade.coinsWon!.abs()} coins lost";
      case Status.ACTIVE_PAIRED:
        return "Trade is Filled";
      case Status.ACTIVE_UNPAIRED:
        return "Trade is not Filled";
      case Status.AUTO_CANCEL:
        return "${trade.coins} coins returned";
      case Status.CANCELLED_BY_USER:
        return "${trade.coins} coins returned";
      default:
        return "";
    }
  }

  Future<List<Map<String, dynamic>>> getUserTradeActivities() async {
    try {
      if (_allLoaded) return _trades;
      setState(() => _isLoading = true);
      List<Map<String, dynamic>> data =
          await _repository.getUserTradeActivities(
        userId: widget.userId,
        lastTradeDate: _lastDate,
        lastTradeId: _lastId,
        pageSize: _pageSize,
      );
      if (data.isEmpty) {
        setState(() => _allLoaded = true);
      } else {
        setState(() => _trades.addAll(data));
        _lastDate = _trades[_trades.length - 1]['trade'].updatedAt;
        _lastId = _trades[_trades.length - 1]['trade'].id;
      }
      setState(() => _isLoading = false);
      return _trades;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return FutureBuilder(
        future: _initialData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constaints) {
              if (_trades.isEmpty) {
                return const Center(
                  child: Text('No trades yet'),
                );
              } else {
                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: _trades.length + (_allLoaded ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _trades.length) {
                          Trade trade = _trades[index]['trade'];
                          return Scrollbar(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: ExpansionTileCard(
                                baseColor: Colors.blueGrey[50],
                                expandedColor: Colors.blueGrey[100],
                                elevation: 10,
                                leading: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: AutoSizeText(
                                    '${trade.coins}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                title: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      10,
                                      0,
                                      0,
                                    ),
                                    child: trade.status == Status.AUTO_CANCEL ||
                                            trade.status ==
                                                Status.CANCELLED_BY_USER
                                        ? AutoSizeText(
                                            '[CANCELLED] ${_trades[index]['question'].name}')
                                        : trade.status == Status.LOST ||
                                                trade.status == Status.WON
                                            ? AutoSizeText(
                                                '[CLOSED] ${_trades[index]['question'].name}')
                                            : AutoSizeText(
                                                '${_trades[index]['question'].name}'),
                                  ),
                                ),
                                children: [
                                  const Divider(
                                    thickness: 1.0,
                                    height: 1.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: AutoSizeText(getTradeStatus(trade),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                          )),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: AutoSizeText(
                                          'Timestamp:  ${DateFormat.yMMMd().format(trade.updatedAt).toString()}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                          )),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child:
                                          AutoSizeText('Trade ID:  ${trade.id}',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                              )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return SizedBox(
                            width: widget.constraints.maxWidth,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: const Center(
                              child: Text('All trades loaded'),
                            ),
                          );
                        }
                      },
                    ),
                    if (_isLoading) ...[
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: widget.constraints.maxWidth,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
            },
          );
        });
  }
}
