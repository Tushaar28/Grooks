import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/my_open_trades_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Users user;
  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final FirebaseRepository _repository;
  late Users _user;
  late bool? _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = null;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    _user = widget.user;
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<Users> getUserDetails() async {
    try {
      Users? user = await _repository.getUserDetails(userId: widget.user.id);
      if (user == null) throw "An error occured";
      _user = user;
      return _user;
    } catch (error) {
      rethrow;
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              child: FutureBuilder<Users>(
                future: getUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: AutoSizeText(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.145,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Align(
                            alignment: const Alignment(0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: snapshot.data!.image != null &&
                                          snapshot.data!.image!.isNotEmpty
                                      ? ClipOval(
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/user.png",
                                            image: snapshot.data!.image!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset("assets/images/user.png"),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: AutoSizeText(
                                    '${snapshot.data?.name}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        color: Color(0xFF777777),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.69,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Align(
                              alignment: Alignment(-1, 0),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: AutoSizeText(
                                  'Your Open Challenges',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: MyOpenTradesScreen(
                                user: _user,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
