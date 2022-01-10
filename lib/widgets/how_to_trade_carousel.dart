import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HowToTradeCarousel extends StatefulWidget {
  final Users user;
  const HowToTradeCarousel({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _HowToTradeCarouselState createState() => _HowToTradeCarouselState();
}

class _HowToTradeCarouselState extends State<HowToTradeCarousel> {
  late final List<String> _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _pages = [
      "assets/images/Trade1.jpg",
      "assets/images/Trade2.jpg",
      "assets/images/Trade3.jpg",
      "assets/images/Trade4.jpg",
      "assets/images/Trade5.jpg",
    ];
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C3857),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          viewportFraction: 1,
          height: MediaQuery.of(context).size.height * 0.85,
        ),
        items: _pages
            .map(
              (image) => SizedBox(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
