import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  final String? maintenanceMessage;
  const MaintenanceScreen({
    Key? key,
    this.maintenanceMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Center(
                child: AutoSizeText(
                  maintenanceMessage ??
                      'App is under maintenance. Please check again after some time.',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
