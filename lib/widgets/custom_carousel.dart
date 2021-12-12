import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomCarousel extends StatefulWidget {
  final List<Map<String, String>> pages;
  const CustomCarousel({
    Key? key,
    required this.pages,
  }) : super(key: key);

  @override
  _CustomCarouselState createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _index = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: (int value) => setState(() => _index = value),
      itemCount: widget.pages.length,
      itemBuilder: (BuildContext context, int index) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.09,
          MediaQuery.of(context).size.height * 0.01,
          0,
          0,
        ),
        child:
            SvgPicture.asset("assets/images/${widget.pages[_index]["image"]}"),
      ),
    );
  }
}
