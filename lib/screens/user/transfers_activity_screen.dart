import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/transfer.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:intl/intl.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class TransfersActivityScreen extends StatefulWidget {
  final String userId;
  final BoxConstraints constraints;
  const TransfersActivityScreen({
    Key? key,
    required this.userId,
    required this.constraints,
  }) : super(key: key);

  @override
  _TransfersActivityScreenState createState() =>
      _TransfersActivityScreenState();
}

class _TransfersActivityScreenState extends State<TransfersActivityScreen> {
  late final FirebaseRepository _repository;
  late List<Map<String, dynamic>> _transfers;
  late DateTime? _lastDate;
  late String? _lastId;
  late final ScrollController _scrollController;
  late bool _isLoading, _allLoaded, _isExpanded, _isActive;
  late int? _prevIndex, _pageSize;
  late Future<List<Map<String, dynamic>>> _initialData;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _transfers = [];
    _pageSize = 20;
    _lastDate = null;
    _lastId = null;
    _isExpanded = _isLoading = _allLoaded = false;
    _isActive = true;
    _initialData = getUserTransferActivities();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        getUserTransferActivities();
      }
    });
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.userId);
    _mixpanel.track("transfers_activity_screen", properties: {
      "userId": widget.userId,
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    // transfers.clear();
    // initialData = getUserTradeActivities();
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
  }

  Future<List<Map<String, dynamic>>> getUserTransferActivities() async {
    try {
      if (_allLoaded) return _transfers;
      setState(() => _isLoading = true);
      List<Map<String, dynamic>> data =
          await _repository.getUserTransferActivities(
        userId: widget.userId,
        lastTradeDate: _lastDate,
        lastTradeId: _lastId,
        pageSize: _pageSize,
      );
      if (data.isEmpty) {
        setState(() => _allLoaded = true);
      } else {
        setState(() => _transfers.addAll(data));
        _lastDate = _transfers[_transfers.length - 1]['transfer'].updatedAt;
        _lastId = _transfers[_transfers.length - 1]['transfer'].id;
      }
      setState(() => _isLoading = false);
      return _transfers;
    } catch (error) {
      throw error.toString();
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
    return RefreshIndicator(
      onRefresh: refresh,
      child: FutureBuilder(
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
              if (_transfers.isEmpty) {
                return const Center(
                  child: Text(
                    'No transfers yet',
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
                      itemCount: _transfers.length + (_allLoaded ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _transfers.length) {
                          Transfer transfer = _transfers[index]['transfer'];
                          Users user = _transfers[index]['user'];
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
                                      MediaQuery.of(context).size.width * 0.2,
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Align(
                                    alignment: const Alignment(0, 0),
                                    child: transfer.receiverId != null
                                        ? AutoSizeText(
                                            '-${transfer.coins}',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 22,
                                              color: Colors.red,
                                            ),
                                          )
                                        : AutoSizeText(
                                            '+${transfer.coins}',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 22,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                  ),
                                ),
                                title: AutoSizeText(
                                  transfer.receiverId != null
                                      ? 'Sent to ${user.name}'
                                      : 'Received from ${user.name}',
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
                                        'Timestamp:  ${DateFormat.yMMMd().format(transfer.createdAt).toString()}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
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
                                          'Transaction ID:  ${transfer.id}',
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
                              child: Text('All transfers loaded'),
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
        },
      ),
    );
  }
}
