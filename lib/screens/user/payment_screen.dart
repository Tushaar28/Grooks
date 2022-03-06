import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  late String _html;
  late bool _dataLoaded;

  @override
  void initState() {
    super.initState();
    _dataLoaded = false;
    getTransactionId();
    _html = "";
  }

  Future<void> getTransactionId() async {
    try {
      var result = await FirebaseFunctions.instance
          .httpsCallable("generateTokenForPayment")
          .call({});
      _html = '''
    <!DOCTYPE html>
  <html>
  <body>
<form action='https://test.payu.in/_payment' method='post'>
<input type='hidden' name="key" value='gtKFFx' />
<input type="hidden" name="txnid" value=${result.data["txnId"]} />
<input type="hidden" name="productinfo" value="phone" />
<input type="hidden" name="amount" value="100" />
<input type="hidden" name="email" value="test@gmail.com" />
<input type="hidden" name="firstname" value="fewfw" />
<input type="hidden" name="lastname" value="Kumar" />
<input type="hidden" name="surl" value="https://apiplayground-response.herokuapp.com/" />
<input type="hidden" name="furl" value="https://apiplayground-response.herokuapp.com/" />
<input type="hidden" name="phone" value="9988776655” />
<input type="hidden" name="hash" value=${result.data["hash"]} />
<input type="submit" value="submit"> </form>
</body>
  </html>
''';
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
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: "https://google.com",
      onWebViewCreated: (controller) {
        _controller = controller;
        _controller.loadHtmlString(_html);
      },
    );
  }
}
