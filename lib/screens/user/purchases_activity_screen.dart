import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/transaction.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../../models/transaction.dart' as model;
import 'package:timeago/timeago.dart' as timeago;

class PurchasesActivityScreen extends StatefulWidget {
  final String userId;
  final BoxConstraints constraints;
  const PurchasesActivityScreen({
    Key? key,
    required this.userId,
    required this.constraints,
  }) : super(key: key);

  @override
  State<PurchasesActivityScreen> createState() =>
      _PurchasesActivityScreenState();
}

class _PurchasesActivityScreenState extends State<PurchasesActivityScreen> {
  late final FirebaseRepository _repository;
  late List<model.Transaction> _purchases;
  late DateTime? _lastDate;
  late String? _lastId;
  late final ScrollController _scrollController;
  late bool _isLoading, _allLoaded, _isExpanded, _isActive;
  late int? _prevIndex, _pageSize;
  late Future<List<model.Transaction>> _initialData;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _purchases = [];
    _pageSize = 20;
    _isExpanded = _allLoaded = _isLoading = false;
    _isActive = true;
    _lastDate = null;
    _lastId = null;
    _initialData = getUserPurchaseActivities();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        getUserPurchaseActivities();
      }
    });
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.userId);
    _mixpanel.track("purchases_activity_screen", properties: {
      "userId": widget.userId,
    });
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
  }

  Future<List<model.Transaction>> getUserPurchaseActivities() async {
    try {
      if (_allLoaded) return _purchases;
      setState(() => _isLoading = true);
      List<model.Transaction> data =
          await _repository.getUserPurchaseActivities(
        userId: widget.userId,
        lastPurchaseDate: _lastDate,
        lastPurchaseId: _lastId,
        pageSize: _pageSize,
      );
      if (data.isEmpty) {
        setState(() => _allLoaded = true);
      } else {
        setState(() => _purchases.addAll(data));
        _lastDate = _purchases[_purchases.length - 1].updatedAt;
        _lastId = _purchases[_purchases.length - 1].id;
      }
      setState(() => _isLoading = false);
      return _purchases;
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
            builder: (context, constraints) {
              if (_purchases.isEmpty) {
                return const Center(
                  child: Text(
                    'No purchases yet',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: _purchases.length + (_allLoaded ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _purchases.length) {
                          model.Transaction purchase = _purchases[index];
                          return Scrollbar(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: ExpansionTileCard(
                                shadowColor: Colors.black,
                                baseColor: Colors.blueGrey[10],
                                expandedColor: Colors.blueGrey[100],
                                elevation: 20,
                                leading: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: AutoSizeText(
                                    "+${purchase.coins}",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: purchase.status ==
                                              TransactionStatus.PROCESSED
                                          ? Theme.of(context).primaryColor
                                          : Colors.red,
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
                                    child: AutoSizeText(
                                      purchase.status ==
                                              TransactionStatus.PROCESSED
                                          ? "${purchase.coins} coins purchased"
                                          : "Purchase Failed",
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
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
                                      child: AutoSizeText(
                                          "Status: ${purchase.status.toString().split('.').last}"),
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
                                          "Coins: ${purchase.coins} "),
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
                                          "Amount: Rs ${purchase.amount.toStringAsFixed(2)} "),
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
                                          "Transaction Date: ${timeago.format(purchase.updatedAt)} "),
                                    ),
                                  ),
                                  if (purchase.transactionId != null) ...[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        child: AutoSizeText(
                                            "Transaction ID: ${purchase.transactionId} "),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        } else {
                          return SizedBox(
                            width: widget.constraints.maxWidth,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: const Center(
                              child: Text('All purchases loaded'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              }
            },
          );
        });
  }
}
