import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';

class ReferralContestScreen extends StatefulWidget {
  final String userId;
  const ReferralContestScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ReferralContestScreen> createState() => _ReferralContestScreenState();
}

class _ReferralContestScreenState extends State<ReferralContestScreen> {
  late final FirebaseRepository _repository;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late bool _isLoading, _dataLoaded;
  bool? _isActive;
  late List<String> rank;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _isLoading = _dataLoaded = false;
    getUserActiveStatus();
    rank = [];
    getInitialReferrals();
    getUserReferrals();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> getInitialReferrals() async {
    try {
      List<Map<String, dynamic>> data = await _repository.getInitialReferrals;
      data.sort((a, b) => a["rank"].compareTo(b["rank"]));
      for (var element in data) {
        rank.insert(element["rank"], element["name"]);
      }
      print("LENGTH INITIAL = ${rank.length}");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserReferrals() async {
    try {
      List<Map<String, dynamic>> data = await _repository.getReferrals;
      data.sort((a, b) => b["referrals"].compareTo(a["referrals"]));
      for (var element in data) {
        rank.add(element["name"]);
        print("LENGTH USER = ${rank.length}");
      }
      setState(() => _dataLoaded = true);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.userId);
    setState(() => _isActive = data);
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
    print("LENGTH = ${rank.length}");
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Referral Contest',
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
        child: ListView.separated(
          itemCount: rank.length,
          itemBuilder: (context, index) => ListTile(
            leading: AutoSizeText(
              "${index + 1}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            title: AutoSizeText(
              rank[index],
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
