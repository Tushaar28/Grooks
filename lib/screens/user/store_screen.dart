import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:grooks_dev/models/user.dart';

class StoreScreen extends StatefulWidget {
  final Users user;
  const StoreScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late bool _isLoading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  Future<void> makePayment() async {
    try {
      setState(() => _isLoading = true);
      String orderId = DateTime.now()
          .toString()
          .replaceAll("-", "")
          .replaceAll(" ", "")
          .replaceAll(":", "")
          .replaceAll(".", "");
      var result = await FirebaseFunctions.instance
          .httpsCallable("generateTokenForPayment")
          .call({
        "orderId": orderId,
        "orderAmount": "13.54",
        "orderCurrency": "INR",
      });
      String stage = "TEST";
      String orderAmount = "13.54";
      String tokenData = result.data["cftoken"];
      String customerName = "Tushaar";
      String orderNote = "Order_Note";
      String orderCurrency = "INR";
      String appId = "123205e8065ff7070dd4b1379c502321";
      String customerPhone = "8968980024";
      String customerEmail = "sample@gmail.com";
      String notifyUrl = "https://test.gocashfree.com/notify";

      Map<String, dynamic> inputParams = {
        "orderId": orderId,
        "orderAmount": orderAmount,
        "customerName": customerName,
        "orderNote": orderNote,
        "orderCurrency": orderCurrency,
        "appId": appId,
        "customerPhone": customerPhone,
        "customerEmail": customerEmail,
        "stage": stage,
        "tokenData": tokenData,
        "notifyUrl": notifyUrl
      };
      CashfreePGSDK.doPayment(inputParams).then((mapData) async {
        try {
          String transactionStatus = mapData!["txStatus"];
          // mapData!.forEach((key, value) {
          //   print("KEY = $key  VALUE = $value");
          // });
          var result = await FirebaseFunctions.instance
              .httpsCallable("verifySignature")
              .call(mapData);
          if (result.data != true) {
            throw "An error occured while verifying your payment";
          }
          if (transactionStatus != "SUCCESS") {
            throw "An error occured";
          }
        } catch (error) {
          rethrow;
        }
      });
    } catch (error) {
      rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: const AutoSizeText(
          'Store',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 22,
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
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.025,
                  MediaQuery.of(context).size.height * 0.025,
                  MediaQuery.of(context).size.width * 0.025,
                  0,
                ),
                child: GridView.builder(
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemBuilder: (context, index) => const Card(
                    color: Colors.greenAccent,
                    elevation: 20,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // body: Center(
      //   child: _isLoading
      //       ? const CircularProgressIndicator.adaptive(
      //           backgroundColor: Colors.white,
      //         )
      //       : TextButton(
      //           child: const Text(
      //             "PAY",
      //             style: TextStyle(
      //               fontSize: 24,
      //             ),
      //           ),
      //           onPressed: () async {
      //             try {
      //               await makePayment();
      //               ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //                 content: Text("Payment successful"),
      //                 backgroundColor: Colors.green,
      //                 duration: Duration(seconds: 2),
      //               ));
      //             } catch (error) {
      //               ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //                 content: Text("An error occured"),
      //                 backgroundColor: Colors.red,
      //                 duration: Duration(seconds: 2),
      //               ));
      //             }
      //           },
      //         ),
      // ),
    );
  }
}
