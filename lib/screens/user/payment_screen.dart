import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_payu_unofficial/flutter_payu_unofficial.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payu_unofficial/models/payment_params_model.dart';
import 'package:flutter_payu_unofficial/models/payment_result.dart';
import 'package:flutter_payu_unofficial/models/payment_status.dart';
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late bool _dataLoaded;
  late String txnId, hash;

  @override
  void initState() {
    super.initState();
    txnId = hash = "";
    _dataLoaded = false;
    getTransactionId();
  }

  Future<void> getTransactionId() async {
    try {
      var result = await FirebaseFunctions.instance
          .httpsCallable("generateTokenForPayment")
          .call({});

      txnId = result.data["txnId"];
      hash = result.data["hash"];

//       _html = '''
//     <!DOCTYPE html>
//   <html>
//   <body>
// <form action='https://test.payu.in/_payment' method='post'>
// <input type='hidden' name="key" value='gtKFFx' />
// <input type="hidden" name="txnid" value=${result.data["txnId"]} />
// <input type="hidden" name="productinfo" value="phone" />
// <input type="hidden" name="amount" value="100" />
// <input type="hidden" name="email" value="test@gmail.com" />
// <input type="hidden" name="firstname" value="fewfw" />
// <input type="hidden" name="lastname" value="Kumar" />
// <input type="hidden" name="surl" value="https://apiplayground-response.herokuapp.com/" />
// <input type="hidden" name="furl" value="https://apiplayground-response.herokuapp.com/" />
// <input type="hidden" name="phone" value="9988776655” />
// <input type="hidden" name="hash" value=${result.data["hash"]} />
// <input type="submit" value="submit"> </form>
// </body>
//   </html>
// ''';
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
    return Center(
      child: TextButton(
        child: const Text("PAY"),
        onPressed: () async {
          try {
            PaymentParams _params = PaymentParams(
              merchantID: "8484926",
              merchantKey: "0Lwahn",
              salt:
                  "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDJYEjrlaZUJ0f3KrormFQueOgVyVRmCjucJBEXNdU+99hdejV8XVF1NEMK277SHKlvWIwZW5az/ZuXydDVPcRrC+qex1OcOhtKqDRyBVbe3Ew5fxM8DyiF83jIi80ILkZzFyZPzbo40v4V5wXlqJhzlvcQgdRV4vjsrB3sHV9JgfwSpcdGprrdQHvltBkhlbw7NI0/eR0IZKoTJNSK2+YHeBTHnbS1tBfEJx42XuIUiSsT+C2ctPcnQR37QuA7bqc+vuQJcoQNxeGsl17wYV3cL88Ohg+clam1YUe7PRnodz7u4wm8fSwzM/9IlCC1j+hQ0cWcyM5H3hM+C3nAJ7MbAgMBAAECggEBALgs0qR8WwJOZthdAKZMjHlwZTs/xmwI4dn9dpAW0TDk9sMPuYlDw/OA1+w/bDe4tRI8Fu4+QQffZAWgM9pDwrfwzyVmwkZ5MmrGiijaT0hGjYRsf4gHiRVxxz8L9XqM8CvkuUp1quK7vl0DzPXti3j0UoSLaUsf6nBzPm6rsnGDzAxKojAEfGGO/uJQd4unaEP7dQ0IebYQMGkpps5yG2ioHVaYvvR4D9PUwNo+d7q6ygFJI7ZCr1zbDu0LiSGTR65V68rfD9YtGxOPXQaqK6uqSKTfFjxQ05od3cTiFswUldcASQQYe4at/ukMnCSdmH41TQhJ4VS5h4uicJKYLtkCgYEA69HScbPMLUgl+EiEcTvSq65KfevCjj0b0xqS/3CidoypJ9oA8H/iQVyfBYBbM3SmC9tEIUbael9q8MAfX0c12c4Evh155gdgJE+gCI2vKn+ZHP/2P4qA3cx2uVUhXZ54+mu95CSoO2WeCHNCxUDykOEuJTajoot24fWQ57oqMQ0CgYEA2pvlyYmMcFn5X5urH24B4gvJKhdg67767QvbdeJXxM+rx4YfBo0HgpCiIkp2+U5728/VFIaEAWBEYwCodrhdv/m5yNg0nzcwjlc8ouaJeroGlPME6RsGQzvHxPUyP9XbzQlvAnVJJvIqLbG2Yxuzra+IynC3YK1COcx+6KtRWscCgYAtNlRHsnYh9GQ7PwQNha+1dLwZelsZ1EOCbOTkDp9HZV6FInntokcpyu0+K8bQjbvMKCTe0GvQ7HxfXiZlqQx9Ds+/93zIin93VsDTAv8jgcVEVxrKQe7FF49npxe3kEuXj5KfrBuJD8mFyztxACvBdTrYraof3udTGTbIBtxR/QKBgHpUHJzPZJAGOR6AHJzk0Rbt426zUF/7Kaz2IqNvug9+6jAnZDslNduhFak8pCDUA0k4npLyxvGCLiJ8Xsi4WHWxx32VRrUFjB1KwbqiaLINYNt+tfO/VJzQ2fPkBW9lO68bpUvp17p8bo/NTzNccAo0HMazlln5+gIf5bBLFaZHAoGAXVtFvLfIizre9mafJjBhICOtrKL2Ycwgxnpfc6hL6sXKPs2kw5c87NmZGEcovOiQ+ZMAMGy4utFmtCDzcYyRUCgezLAxAZRtKimrGlNtv0g/DSi9Io5TIiCUD0HChDhHji7PyRWaBGofiFRwDh1HfeuswhNb5msz32Ki/pWpL/0=",
              amount: "100",
              transactionID: txnId,
              phone: "8968980024",
              productName: "phone",
              firstName: "fewfw",
              email: "test@gmail.com",
              sURL: "https://www.payumoney.com/mobileapp/payumoney/success.php",
              fURL: "https://www.payumoney.com/mobileapp/payumoney/failure.php",
              udf1: "",
              udf2: "",
              udf3: "",
              udf4: "",
              udf5: "",
              udf6: "",
              udf7: "",
              udf8: "",
              udf9: "",
              udf10: "",
              hash: "",
              isDebug: true,
            );
            var bytes = utf8.encode(
                "${_params.merchantKey}|${_params.transactionID}|${_params.amount}|${_params.productName}|${_params.firstName}|${_params.email}|||||||||||${_params.salt}");
            String localHash = sha512.convert(bytes).toString();
            _params.hash = localHash;
            PayuPaymentResult _paymentResult =
                await FlutterPayuUnofficial.initiatePayment(
              paymentParams: _params,
              showCompletionScreen: true,
            );
            if (_paymentResult != null) {
              //_paymentResult.status is String of course. Directly fetched from payU's Payment response. More statuses can be compared manually

              if (_paymentResult.status == PayuPaymentStatus.success) {
                print("Success: ${_paymentResult.response}");
              } else if (_paymentResult.status == PayuPaymentStatus.failed) {
                print("Failed: ${_paymentResult.response}");
              } else if (_paymentResult.status == PayuPaymentStatus.cancelled) {
                print("Cancelled by User: ${_paymentResult.response}");
              } else {
                print("Response: ${_paymentResult.response}");
                print("Status: ${_paymentResult.status}");
              }
            } else {
              print("Something's rotten here");
            }
          } catch (error) {
            print("ERROR = $error");
          }
        },
      ),
    );
  }
}
