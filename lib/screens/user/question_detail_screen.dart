import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/open_questions_screen.dart';
import 'package:grooks_dev/screens/user/top_trades_screen.dart';
import 'package:grooks_dev/screens/user/trade_success_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/question_card.dart';
import 'package:grooks_dev/widgets/swipe_button.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'error_screen.dart';
import 'my_trades_screen.dart';

// ignore: must_be_immutable
class QuestionDetailScreen extends StatefulWidget {
  final Users user;
  final String questionId;
  final String? questionName;
  Map<String, dynamic>? sharedViewMap;
  QuestionDetailScreen({
    Key? key,
    required this.user,
    required this.questionId,
    this.questionName,
    this.sharedViewMap,
  }) : super(key: key);

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late int _currentTrade;
  late int _count, _commissionCoins;
  late bool? _tradePlaced,
      _tradeError,
      _isLoading,
      _done,
      _isOpen,
      _isActive,
      _dataLoaded;
  Question? _question;
  late final AssetsAudioPlayer _player;
  late double _winCommission;
  late final Mixpanel _mixpanel;
  final _viewSuccessSnackbar = const SnackBar(
    content: AutoSizeText('Your trade has been placed.'),
    backgroundColor: Colors.green,
  );
  final _viewFailureSnackbar = const SnackBar(
    content: AutoSizeText('An error occured.'),
    backgroundColor: Colors.red,
  );

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isActive = true;
    _count = 1;
    _dataLoaded = false;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _repository = FirebaseRepository();
    _isLoading = _done = false;
    _winCommission = 0;
    _player = AssetsAudioPlayer();
    getQuestionDetails();
    getWinCommission();
    if (widget.sharedViewMap != null &&
        widget.sharedViewMap!.containsKey('isYes') &&
        widget.sharedViewMap!.containsKey('tradedPrice')) {
      _currentTrade = 100 - widget.sharedViewMap!['tradedPrice'] as int;
    } else {
      _currentTrade = 50;
    }
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("question_detail_screen", properties: {
      "userId": widget.user.id,
    });
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  Future<void> getWinCommission() async {
    _winCommission = await _repository.getWinCommission;
    setState(() => _dataLoaded = true);
  }

  Future<void> getUserActiveStatus() async {
    _isActive = await _repository.getUserActiveStatus(userId: widget.user.id);
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Future<Question> getQuestionDetails() async {
    try {
      _question =
          await _repository.getQuestionDetails(questionId: widget.questionId);
      _isOpen = _question!.closedAt == null;
      return _question!;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> placeTrade({
    required bool isYes,
  }) async {
    try {
      bool isQuestionActive = await _repository.getQuestionActiveStatus(
          questionId: widget.questionId);
      if (isQuestionActive == false) {
        throw 'An error occured';
      }
      int bonusCoins =
          await _repository.getUserBonusCoins(userId: widget.user.id);
      int redeemableCoins =
          await _repository.getUserRedeemableCoins(userId: widget.user.id);
      if ((_currentTrade * _count) > (bonusCoins + redeemableCoins)) {
        throw 'Insufficient coins';
      }

      await _repository.placeTrade(
        bet: _currentTrade,
        bonusCoins: bonusCoins,
        count: _count,
        questionId: widget.questionId,
        redeemableCoins: redeemableCoins,
        response: isYes,
        userId: widget.user.id,
      );
      _player.open(Audio("assets/audios/success.mp3"));
    } catch (error) {
      throw error.toString();
    } finally {
      setState(() {
        _isLoading = false;
        _done = false;
      });
    }
  }

  Future<void> showTradeSlider({
    required BuildContext context,
    required bool isYes,
  }) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: const Color(0xFFCDE5FF),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFFCDE5FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Number of trades",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.03,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF1C3857),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                    child: IconButton(
                                      padding: EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.width *
                                            0.01,
                                        0,
                                        0,
                                        MediaQuery.of(context).size.width *
                                            0.001,
                                      ),
                                      icon: const Icon(
                                        Icons.remove,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        if (_count > 1) {
                                          setState(() => _count--);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1C3857),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "$_count",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                    child: IconButton(
                                      padding: EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.width *
                                            0.01,
                                        0,
                                        0,
                                        MediaQuery.of(context).size.width *
                                            0.001,
                                      ),
                                      icon: const Icon(
                                        Icons.add,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        if (_count < 10) {
                                          setState(() => _count++);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey[700],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.17,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Your trading amount",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Your Potential Win",
                                style: TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "$_currentTrade",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${100 - _currentTrade}",
                                style: const TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: const SliderThemeData(
                              thumbColor: Color(0xFF1C3857),
                            ),
                            child: Slider(
                              activeColor: const Color(0xFF1C3857),
                              value: _currentTrade.toDouble(),
                              onChanged: (value) => setState(
                                () => _currentTrade = value.toInt(),
                              ),
                              inactiveColor: const Color(0XFF007AFF),
                              min: 5,
                              max: 95,
                              divisions: 18,
                              label: _currentTrade.toInt().toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey[700],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "If Final Outcome is : ${isYes ? "Yes" : "No"}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "You make profit of : ${100 - _currentTrade} coins",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Else you will lose : $_currentTrade coins",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Text(
                            "Your coins will be multiplied with number of trades",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "10 ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Image.asset("assets/images/coins.png",
                                  scale: 1.2),
                              const Text(
                                " = ₹1 ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "So you can earn equivalent of ₹10 from 1 trade.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "${(_winCommission / 100 * (100 - _currentTrade)).ceil()} coins will be deducted as commission from your winning",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey[700],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.065,
                      child: _isLoading!
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : _done!
                              ? const SizedBox(
                                  width: 0,
                                  height: 0,
                                )
                              : SwipeButton(
                                  text: 'Slide to Confirm',
                                  height: MediaQuery.of(context).size.height *
                                      0.065,
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  color: isYes
                                      ? Theme.of(context).primaryColor
                                      : Colors.red,
                                  backgroundColorEnd: isYes
                                      ? Colors.blueAccent[100]
                                      : Colors.redAccent[100],
                                  onSwipeCallback: () async {
                                    try {
                                      setState(() => _isLoading = true);
                                      await placeTrade(
                                        isYes: isYes,
                                      );
                                      for (int i = 0; i < _count; i++) {
                                        _mixpanel.identify(widget.user.id);
                                        _mixpanel.track(
                                          "new_trade_success",
                                          properties: {
                                            "userId": widget.user.id,
                                            "questionId": widget.questionId,
                                            "questionName": widget.questionName,
                                            "tradeCount": _count,
                                          },
                                        );
                                      }
                                      setState(() => _isLoading = false);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TradeSuccessScreen(
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    } catch (error) {
                                      for (int i = 0; i < _count; i++) {
                                        _mixpanel.identify(widget.user.id);
                                        _mixpanel.track(
                                          "new_trade_failed",
                                          properties: {
                                            "userId": widget.user.id,
                                            "questionId": widget.questionId,
                                            "questionName": widget.questionName,
                                            "tradeCount": _count,
                                          },
                                        );
                                      }
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      if (error.toString() ==
                                          "Insufficient coins") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text("Insufficient coins"),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text("An error occured"),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                      rethrow;
                                    }
                                  },
                                ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateDoneStatus() async {
    setState(() => _done = false);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (widget.sharedViewMap != null &&
          widget.sharedViewMap!.containsKey('isYes')) {
        showTradeSlider(
          context: context,
          isYes: !widget.sharedViewMap!['isYes'],
        );
        widget.sharedViewMap = null;
      }
    });

    if (_isActive == null || _dataLoaded == false) {
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
    return FutureBuilder(
      future: getQuestionDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.white,
            ),
          );
        }
        if (snapshot.hasError) {
          return ErrorScreen(
            user: widget.user,
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: true,
            title: const AutoSizeText(
              "Details",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
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
          body: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.895,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.025,
                    10,
                    MediaQuery.of(context).size.width * 0.025,
                    10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      QuestionCard(
                        question: _question!,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          initialIndex: 0,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Theme.of(context).primaryColor,
                                indicatorColor: const Color(0xFFEE8B60),
                                tabs: const [
                                  Tab(
                                    text: 'TOP TRADES',
                                  ),
                                  Tab(
                                    text: 'MY TRADES',
                                  )
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    TopTradesScreen(
                                      question: _question!,
                                      user: widget.user,
                                    ),
                                    MyTradesScreen(
                                      user: widget.user,
                                      question: _question!,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_question!.answer == null) ...[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(
                                child: AutoSizeText(
                                  "Select your Opinion",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.grey,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.045,
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await showTradeSlider(
                                      context: context,
                                      isYes: true,
                                    );
                                  } catch (error) {}
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green[100],
                                  side: const BorderSide(
                                    color: Color(0x40269E3D),
                                  ),
                                  minimumSize: Size.fromWidth(
                                    MediaQuery.of(context).size.width * 0.4,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "YES",
                                    style: TextStyle(color: Colors.green[600]),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await showTradeSlider(
                                      context: context,
                                      isYes: false,
                                    );
                                  } catch (error) {}
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.deepOrange[100],
                                  side: const BorderSide(
                                    color: Color(0xFFEB6821),
                                  ),
                                  minimumSize: Size.fromWidth(
                                    MediaQuery.of(context).size.width * 0.4,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "NO",
                                    style: TextStyle(color: Colors.deepOrange),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_question!.answer != null) ...[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              (_question!.answer)!
                                  ? "Event settled at Yes"
                                  : "Event settled at No",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: (_question!.answer)!
                                    ? Colors.green[600]
                                    : const Color(0xFFEB6821),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
