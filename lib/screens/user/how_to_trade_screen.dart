import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/how_to_trade_carousel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

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
  late final Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("how_to_trade_screen", properties: {
      "userId": widget.user.id,
    });
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
          'How to trade',
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
      body: HowToTradeCarousel(user: widget.user),
    );
  }
}
