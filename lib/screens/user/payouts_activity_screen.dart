import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/payout.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class PayoutsAcivityScreen extends StatefulWidget {
  final String userId;
  final BoxConstraints constraints;
  const PayoutsAcivityScreen({
    Key? key,
    required this.userId,
    required this.constraints,
  }) : super(key: key);

  @override
  State<PayoutsAcivityScreen> createState() => _PayoutsAcivityScreenState();
}

class _PayoutsAcivityScreenState extends State<PayoutsAcivityScreen> {
  late final FirebaseRepository _repository;
  late List<Payout> _payouts;
  late DateTime? _lastDate;
  late String? _lastId;
  late final ScrollController _scrollController;
  late bool _isLoading, _allLoaded, _isExpanded, _isActive;
  late int? _prevIndex, _pageSize;
  late Future<List<Payout>> _initialData;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _payouts = [];
    _pageSize = 20;
    _isExpanded = _allLoaded = _isLoading = false;
    _isActive = true;
    _lastDate = null;
    _lastId = null;
    _initialData = getUserPayoutActivities();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        getUserPayoutActivities();
      }
    });
  }

  Color getPayoutColor(Payout payout) {
    if (payout.status == PayoutStatus.FAILED) return Colors.red;
    if (payout.status == PayoutStatus.PENDING) return Colors.grey;
    if (payout.status == PayoutStatus.PROCESSING) return Colors.yellow.shade700;
    return Colors.blue;
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
  }

  Future<List<Payout>> getUserPayoutActivities() async {
    try {
      if (_allLoaded) return _payouts;
      setState(() => _isLoading = true);
      List<Payout> data = await _repository.getUserPayoutActivities(
        userId: widget.userId,
        lastPayoutDate: _lastDate,
        lastPayoutId: _lastId,
        pageSize: _pageSize,
      );
      if (data.isEmpty) {
        setState(() => _allLoaded = true);
      } else {
        setState(() => _payouts.addAll(data));
        _lastDate = _payouts[_payouts.length - 1].updatedAt;
        _lastId = _payouts[_payouts.length - 1].id;
      }
      setState(() => _isLoading = false);
      return _payouts;
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
              if (_payouts.isEmpty) {
                return const Center(
                  child: Text(
                    'No payouts yet',
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
                      itemCount: _payouts.length + (_allLoaded ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _payouts.length) {
                          Payout payout = _payouts[index];
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
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: AutoSizeText(
                                    "Rs ${payout.requestedAmount}",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: getPayoutColor(payout),
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
                                      payout.upi != null
                                          ? "UPI Transfer"
                                          : "Bank Transfer",
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
                                          "Status: ${payout.status.toString().split('.').last}"),
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
                                          "Commission: Rs ${payout.commission.toStringAsFixed(2)} "),
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
                                          "Final Amount: Rs ${payout.finalAmount.toStringAsFixed(2)} "),
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
                                          "Transaction ID: ${payout.id} "),
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
                                          "Transaction Date: ${timeago.format(payout.updatedAt)} "),
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
                              child: Text('All payouts loaded'),
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