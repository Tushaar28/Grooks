import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:grooks_dev/widgets/custom_button.dart';

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
  late TextEditingController _coinsController;
  late final FirebaseRepository _repository;
  late bool _isLoading, _hasDataLoaded, _done;
  late double _paymentGatewayCommission, _price, _paymentCharges, _totalAmount;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<String> _packs;

  @override
  void initState() {
    super.initState();
    _hasDataLoaded = false;
    _repository = FirebaseRepository();
    getPaymentGatewayCommission();
    _isLoading = _done = false;
    _packs = [
      "assets/images/pack1.png",
      "assets/images/pack2.png",
      "assets/images/pack3.png",
      "assets/images/pack4.png",
    ];
    _price = 0;
    _paymentCharges = 0;
    _totalAmount = 0;
    _coinsController = TextEditingController();
  }

  Future<void> getPaymentGatewayCommission() async {
    _paymentGatewayCommission = await _repository.getPaymentGatewayCommission;
    setState(() => _hasDataLoaded = true);
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
      var result =
          await FirebaseFunctions.instance.httpsCallable("generateOrder").call({
        "orderId": orderId,
        "orderAmount": "0.23",
        "orderCurrency": "INR",
      });
      String stage = "PROD";
      String orderAmount = "0.23";
      String tokenData = result.data["cftoken"];
      String customerName = widget.user.name;
      String orderNote = "GROOKS_COINS_PURCHASE";
      String orderCurrency = "INR";
      String appId = "1938418bee28dee03922c6a986148391";
      String customerPhone = widget.user.mobile?.substring(2) ?? "";
      String customerEmail = "payment@grooks.in";

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
      };
      CashfreePGSDK.doPayment(inputParams).then((mapData) async {
        try {
          String transactionStatus = mapData!["txStatus"];
          var result = await FirebaseFunctions.instance
              .httpsCallable("verifySignature")
              .call(mapData);
          await updateTransactionDetails(
            transactionId: mapData["referenceId"],
            transactionStatus: transactionStatus,
            userId: widget.user.id,
            amount: _totalAmount,
            coins: int.parse(_coinsController.text),
          );
          if (result.data != true) {
            throw "An error occured while verifying your payment";
          }
          if (transactionStatus != "SUCCESS") {
            throw "An error occured";
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
            _done = false;
          });
          ScaffoldMessenger.maybeOf(context)!.hideCurrentSnackBar();
          ScaffoldMessenger.maybeOf(context)!.showSnackBar(
            const SnackBar(
              content: Text("Payment failed. Please try again"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          rethrow;
        }
        ScaffoldMessenger.maybeOf(context)!.hideCurrentSnackBar();
        ScaffoldMessenger.maybeOf(context)!.showSnackBar(
          const SnackBar(
            content: Text("Payment successful"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
      setState(() {
        _isLoading = false;
        _done = true;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _done = false;
      });
      rethrow;
    }
  }

  bool isCoinsValid() {
    bool isValid = int.tryParse(_coinsController.text) != null &&
        int.tryParse(_coinsController.text)! >= 100;
    if (isValid) {
      _price = int.parse(_coinsController.text) / 10;
      _paymentCharges = _paymentGatewayCommission /
          100 *
          (int.parse(_coinsController.text) / 10);
      _totalAmount = (int.parse(_coinsController.text) / 10) +
          (_paymentGatewayCommission /
              100 *
              (int.parse(_coinsController.text) / 10));
    }
    return isValid;
  }

  Future<void> updateTransactionDetails({
    required String transactionStatus,
    String? transactionId,
    required String userId,
    required double amount,
    required int coins,
  }) async {
    bool isSuccess = transactionStatus == "SUCCESS" ? true : false;
    await _repository.updateTransactionDetails(
      transactionStatus: isSuccess,
      transactionId: transactionId,
      userId: userId,
      amount: amount,
      coins: coins,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
      body: !_hasDataLoaded
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            )
          : SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.025,
                  0,
                  MediaQuery.of(context).size.width * 0.025,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      color: Colors.transparent,
                      padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.height * 0.025,
                        0,
                        0,
                      ),
                      child: GridView.builder(
                        itemCount: _packs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0.0,
                        ),
                        itemBuilder: (context, index) => InkWell(
                          child: Card(
                            child: Image.asset(_packs[index]),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.1,
                        MediaQuery.of(context).size.height * 0.01,
                        MediaQuery.of(context).size.width * 0.1,
                        0,
                      ),
                      child: TextField(
                        controller: _coinsController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        obscureText: false,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Coins',
                          hintText: 'Enter coins (Minimum 100 coins)',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightBlueAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    if (isCoinsValid()) ...[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        padding: EdgeInsets.fromLTRB(
                          0,
                          MediaQuery.of(context).size.height * 0.01,
                          0,
                          0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: const Text("Price"),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Center(
                                    child: Text("Rs $_price"),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: const Text("Payment charges"),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Center(
                                    child: Text(
                                        "Rs ${_paymentCharges.toStringAsFixed(2)}"),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: const Text("Total Amount"),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Center(
                                    child: Text(
                                        "Rs ${_totalAmount.toStringAsFixed(2)}"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: _done
                            ? null
                            : _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator.adaptive(
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                : CustomButton(
                                    onPressed: () async {
                                      try {
                                        setState(() => _isLoading = true);
                                        await makePayment();
                                      } catch (error) {
                                        print("ERROR = $error");
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    },
                                    text: "BUY",
                                  ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
