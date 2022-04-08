import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/how_to_trade_carousel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late String _videoLink;
  late bool _dataLoaded;
  late final FirebaseRepository _repository;

  @override
  void initState() {
    super.initState();
    _dataLoaded = false;
    _initMixpanel();
    _videoLink = "";
    _repository = FirebaseRepository();
    getVideoLink();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.user.id);
    _mixpanel.track("how_to_trade_screen", properties: {
      "userId": widget.user.id,
    });
  }

  Future<void> getVideoLink() async {
    try {
      String? link = await _repository.getVideoLink;
      if (link != null && link.isNotEmpty) {
        _videoLink = link;
      }
      setState(() => _dataLoaded = true);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dataLoaded == false) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }
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
        actions: [
          if (_videoLink.isNotEmpty) ...[
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill_outlined,
                size: 30,
              ),
              onPressed: () async => await launch(_videoLink),
            ),
          ],
        ],
      ),
      body: HowToTradeCarousel(user: widget.user),
    );
  }
}
