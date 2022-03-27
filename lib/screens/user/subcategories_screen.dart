import 'package:flutter/material.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/subcategory_card.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class SubcategoriesScreen extends StatefulWidget {
  final Category category;
  final Users user;
  const SubcategoriesScreen({
    Key? key,
    required this.category,
    required this.user,
  }) : super(key: key);

  @override
  _SubcategoriesScreenState createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  late List<Category> _subcategories;
  late final FirebaseRepository _repository;
  late bool _isDataLoaded;
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _repository = FirebaseRepository();
    _isDataLoaded = false;
    getSubcategoriesFromCategory();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("subcategories_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Future<void> refresh({
    required BuildContext context,
  }) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NavbarScreen(
          user: widget.user,
        ),
      ),
    );
  }

  Future<void> getSubcategoriesFromCategory() async {
    setState(() => _isDataLoaded = false);
    _subcategories = await _repository.getSubcategoriesFromCategory(
        categoryId: widget.category.id);
    setState(() => _isDataLoaded = true);
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

    return RefreshIndicator(
      onRefresh: () => refresh(context: context),
      child: FutureBuilder(
          future: getSubcategoriesFromCategory(),
          builder: (context, snapshot) {
            if (_subcategories.isEmpty) {
              return const Center(
                child: Text(
                  "No events",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.center,
              child: ListView.builder(
                itemCount: _subcategories.length,
                itemBuilder: (context, index) {
                  return CustomSubcategoryCard(
                    user: widget.user,
                    subcategory: _subcategories[index],
                  );
                },
              ),
            );
          }),
    );
  }
}
