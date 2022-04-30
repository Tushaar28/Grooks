import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewReferralsScreen extends StatefulWidget {
  final String userId;
  const ViewReferralsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewReferralsScreen> createState() => _ViewReferralsScreenState();
}

class _ViewReferralsScreenState extends State<ViewReferralsScreen> {
  late final _scaffoldKey;
  late final FirebaseRepository _repository;
  late List<Map<String, dynamic>>? _users;
  late bool? _isActive;
  late bool _isLoading, _dataLoaded;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _repository = FirebaseRepository();
    _isActive = true;
    getUserActiveStatus();
    _isLoading = _dataLoaded = false;
    getUserReferrals();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.userId);
    _mixpanel.track("view_referrals_screen", properties: {
      "userId": widget.userId,
    });
  }

  Future<void> getUserActiveStatus() async {
    try {
      bool data = await _repository.getUserActiveStatus(userId: widget.userId);
      setState(() => _isActive = data);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserReferrals() async {
    try {
      List<Map<String, dynamic>> data =
          await _repository.getUserReferrals(userId: widget.userId);
      _users = data;
      _users!.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      setState(() => _dataLoaded = true);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Referred Users',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: _users == null || _users!.isEmpty
            ? const Center(
                child: AutoSizeText(
                  "No users referred",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _users!.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ExpansionTileCard(
                    shadowColor: Colors.black,
                    baseColor: Colors.blueGrey[10],
                    expandedColor: Colors.blueGrey[100],
                    elevation: 20,
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: AutoSizeText(
                        "+ ${_users![index]['referralCoins']}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          10,
                          0,
                          0,
                        ),
                        child: AutoSizeText(
                          "${_users![index]['name']}",
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
                            "Mobile: ${_users![index]['mobile'].substring(3)}",
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
                            "Timestamp: ${timeago.format(_users![index]['createdAt'].toDate())}",
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
              ),
      ),
    );
  }
}
