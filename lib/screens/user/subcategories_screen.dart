import 'package:flutter/material.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/screens/user/navbar_screen.dart';
import 'package:grooks_dev/widgets/custom_subcategory_card.dart';

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
  late final List<Category> _subcategories;
  late final FirebaseRepository _repository;
  late bool _isDataLoaded;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseRepository();
    _isDataLoaded = false;
    getSubcategoriesFromCategory();
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
    return RefreshIndicator(
      onRefresh: () => refresh(context: context),
      child: Align(
        alignment: Alignment.center,
        child: ListView.builder(
          itemCount: _subcategories.length,
          itemBuilder: (context, index) => CustomSubcategoryCard(
            subcategory: _subcategories[index],
          ),
        ),
      ),
    );
  }
}
