import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/authentication/login_screen.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/screens/user/subcategories_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_tabview.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class HomeScreen extends StatefulWidget {
  final Users user;
  const HomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final List<Category> _categories;
  late int _index;
  late bool _isDataLoaded;
  late bool? _isActive;
  late final FirebaseRepository _repository;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _isActive = null;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _index = 0;
    _isDataLoaded = false;
    _repository = FirebaseRepository();
    getUserActiveStatus();
    getCategories();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("home_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Future<void> refresh({
    required BuildContext context,
  }) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NavbarScreen(user: widget.user),
      ),
    );
  }

  Future<void> getUserActiveStatus() async {
    bool data = await _repository.getUserActiveStatus(userId: widget.user.id);
    setState(() => _isActive = data);
  }

  Future<List<Category>> getCategories() async {
    _categories = await _repository.getAllCategories;
    setState(() => _isDataLoaded = true);
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    if (_isActive == false) {
      _repository.signOut();
      SchedulerBinding.instance!.addPostFrameCallback(
        (timeStamp) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      );
    }
    if (_isDataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () => refresh(context: context),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: _categories.isEmpty
                  ? const Center(
                      child: Text(
                        "No categories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        CustomTabView(
                          initPosition: _index,
                          onPositionChange: (int? value) {
                            _mixpanel.identify(widget.user.id);
                            _mixpanel.track("category_clicked", properties: {
                              "categoryId": _categories[value!].id,
                              "categoryName": _categories[value].name,
                            });
                            setState(() => _index = value);
                          },
                          itemCount: _categories.length,
                          tabBuilder: (context, index) {
                            _index = index;
                            return Tab(
                              height: MediaQuery.of(context).size.height * 0.1,
                              text: _categories[_index].name,
                              icon: CircleAvatar(
                                radius:
                                    MediaQuery.of(context).size.width * 0.07,
                                backgroundColor: Colors.transparent,
                                child: _categories[_index].image == null ||
                                        _categories[_index].image!.isEmpty
                                    ? Image.asset("assets/images/fallback.png")
                                    : FadeInImage.assetNetwork(
                                        placeholder:
                                            "assets/images/fallback.png",
                                        image: _categories[_index].image ??
                                            "assets/images/fallback.png"),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Expanded(
                          child: SubcategoriesScreen(
                            category: _categories[_index],
                            user: widget.user,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
