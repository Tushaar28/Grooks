import 'package:flutter/material.dart';
import 'package:grooks_dev/models/user.dart';

import 'my_closed_trades_screen.dart';
import 'my_open_trades_screen.dart';

class FavouriteTradesScreen extends StatefulWidget {
  final Users user;
  const FavouriteTradesScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _FavouriteTradesScreenState createState() => _FavouriteTradesScreenState();
}

class _FavouriteTradesScreenState extends State<FavouriteTradesScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  final List<String> categories = ['OPEN', 'CLOSED'];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.895,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    initialIndex: 0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: TabBar(
                            labelColor: const Color(0xFF130F26),
                            indicator: BoxDecoration(
                              color: const Color(0x402DEB51),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            tabs: const [
                              Tab(
                                text: 'OPEN',
                              ),
                              Tab(
                                text: 'CLOSED',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              //OPEN page
                              MyOpenTradesScreen(user: widget.user),
                              // CLOSED page
                              MyClosedTradesScreen(user: widget.user),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
