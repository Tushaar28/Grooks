import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/widgets/how_to_trade_carousel.dart';

class HowToTradeScreen extends StatefulWidget {
  final Users user;
  const HowToTradeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _HowToTradeScreenState createState() => _HowToTradeScreenState();
}

class _HowToTradeScreenState extends State<HowToTradeScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'How To Trade',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        // actions: [
        //   SizedBox(
        //     child: IconButton(
        //       onPressed: () {},
        //       icon: const Icon(Icons.play_circle_outline_outlined),
        //       iconSize: 40,
        //       color: Colors.grey,
        //     ),
        //   ),
        // ],
        centerTitle: false,
        elevation: 0,
      ),
      body: HowToTradeCarousel(user: widget.user),
    );
  }
}
