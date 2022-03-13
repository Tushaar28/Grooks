import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class WithdrawlScreen extends StatelessWidget {
  const WithdrawlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: const AutoSizeText(
            'Withdraw',
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
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Image.asset("assets/images/withdraw.jpg"),
        ),
      ),
    );
  }
}
