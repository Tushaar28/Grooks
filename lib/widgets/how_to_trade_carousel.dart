import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';

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
  late final List<Map<String, dynamic>> _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        "image": "assets/images/how_to_trade_fg.png",
        "text": "hiuewhfiwehfwhfgwbnfiubwfuwfewfwgwrgw",
        "button": "assets/images/how_to_trade_button_next.png",
      },
      {
        "image": "assets/images/how_to_trade_fg.png",
        "text": "iukuyjktjukyktuktuktuktkutkutukutktukuk",
        "button": "assets/images/how_to_trade_button1.png",
      },
      {
        "image": "assets/images/how_to_trade_fg.png",
        "text": "hiuewhfiwehfwhfgwbnfiubwfuwfewfwgwrgw",
        "button": "assets/images/how_to_trade_button2.png",
      },
      {
        "image": "assets/images/how_to_trade_fg.png",
        "text": "iukuyjktjukyktuktuktuktkutkutukutktukuk",
        "button": "assets/images/how_to_trade_button3.png",
      },
      {
        "image": "assets/images/how_to_trade_fg.png",
        "text": "iukuyjktjukyktuktuktuktkutkutukutktukuk",
        "button": "assets/images/how_to_trade_button_finished.png",
      },
    ];
    _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.075),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0x25007AFF),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.04,
                    MediaQuery.of(context).size.height * 0.19,
                    MediaQuery.of(context).size.width * 0.04,
                    MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Text(
                    _pages[_index]["text"],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.125,
              child: InkWell(
                child: Image.asset(_pages[_index]["button"]),
                onTap: () =>
                    setState(() => _index = (_index + 1) % _pages.length),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: Image.asset(_pages[_index]["image"]),
        ),
      ],
    );
  }
}
