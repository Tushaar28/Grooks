import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/home_screen.dart';
import 'package:grooks_dev/widgets/custom_appbar.dart';
import 'package:grooks_dev/widgets/custom_drawer.dart';

class NavbarScreen extends StatefulWidget {
  Users? user;
  final String? initialPage;
  NavbarScreen({
    Key? key,
    this.user,
    this.initialPage,
  }) : super(key: key);

  @override
  _NavbarScreenState createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  late String _currentPage;
  late bool _isDataLoaded;
  late final FirebaseRepository _repository;
  late bool? _isActive;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late Map<String, Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    _tabs = {};
    _isDataLoaded = widget.user != null;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _currentPage = widget.initialPage ?? 'Home';
    _repository = FirebaseRepository();
    if (widget.user == null) {
      getCurrentUser();
    }
  }

  Future<void> getCurrentUser() async {
    try {
      Users? user = await _repository.getUserDetails();
      if (user != null) {
        widget.user = user;

        setState(() => _isDataLoaded = true);
      }
      getUserActiveStatus();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user!.id);
    setState(() => _isActive = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
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
    _tabs = {
      'Home': HomeScreen(user: widget.user!),
      'My Trades': const Center(
        child: Text("My trades"),
      ),
      'Profile': const Center(
        child: Text("Profile"),
      ),
    };

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(context: context, user: widget.user!),
      appBar: CustomAppbar(
        scaffoldKey: _scaffoldKey,
        userId: widget.user!.id,
        context: context,
      ),
      body: _tabs[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 28,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 28,
            ),
            label: "My trades",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.user,
              size: 26,
            ),
            label: "Profile",
          ),
        ],
        backgroundColor: Colors.white,
        currentIndex: _tabs.keys.toList().indexOf(_currentPage),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color(0x8A000000),
        onTap: (i) => setState(() => _currentPage = _tabs.keys.toList()[i]),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
