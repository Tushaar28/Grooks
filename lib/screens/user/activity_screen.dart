import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grooks_dev/screens/user/payouts_activity_screen.dart';
import 'package:grooks_dev/screens/user/purchases_activity_screen.dart';
import 'package:grooks_dev/screens/user/trades_activity_screen.dart';
import 'package:grooks_dev/screens/user/transfers_activity_screen.dart';
import 'package:grooks_dev/services/mixpanel.dart';
import 'package:grooks_dev/widgets/custom_dropdown.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class ActivityScreen extends StatefulWidget {
  final String userId;
  String chosenOption;
  ActivityScreen({
    Key? key,
    required this.userId,
    this.chosenOption = 'Trades',
  }) : super(key: key);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late Mixpanel _mixpanel;

  @override
  void initState() {
    super.initState();
    _initMixpanel();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<void> _initMixpanel() async {
    _mixpanel = await MixpanelManager.init();
    _mixpanel.identify(widget.userId);
    _mixpanel.track("activity_screen", properties: {
      "userId": widget.userId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'My Activities',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 1,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: AutoSizeText(
                        'Choose type of activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: FlutterFlowDropDown(
                        initialOption: widget.chosenOption,
                        options: const [
                          'Trades',
                          'Purchases',
                          'Withdrawls',
                          'Transfers'
                        ],
                        onChanged: (value) {
                          SchedulerBinding.instance!.addPostFrameCallback(
                              (timeStamp) =>
                                  setState(() => widget.chosenOption = value!));
                        },
                        width: 130,
                        height: 40,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        fillColor: Colors.white,
                        elevation: 2,
                        borderColor: Theme.of(context).primaryColor,
                        borderWidth: 1,
                        borderRadius: 10,
                        margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (widget.chosenOption.toLowerCase() == 'trades') {
                      return TradesActivityScreen(
                          userId: widget.userId, constraints: constraints);
                    } else if (widget.chosenOption.toLowerCase() ==
                        'purchases') {
                      return PurchasesActivityScreen(
                          userId: widget.userId, constraints: constraints);
                    } else if (widget.chosenOption.toLowerCase() ==
                        'transfers') {
                      return TransfersActivityScreen(
                          userId: widget.userId, constraints: constraints);
                    }

                    return PayoutsAcivityScreen(
                        userId: widget.userId, constraints: constraints);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
