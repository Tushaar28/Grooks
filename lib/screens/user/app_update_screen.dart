import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/widgets/custom_button.dart';
import 'package:ota_update/ota_update.dart';

// ignore: must_be_immutable
class AppUpdateScreen extends StatefulWidget {
  String link;
  AppUpdateScreen({
    Key? key,
    required this.link,
  })  : assert(link.isNotEmpty),
        super(key: key);

  @override
  _AppUpdateScreenState createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  showProgressIndicator({String? value}) {
    Center(
      child: LinearProgressIndicator(
        backgroundColor: Colors.white,
        color: Colors.blue,
        minHeight: 50,
        value: double.tryParse(value!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomSheet: StatefulBuilder(
          builder: (BuildContext context, setState) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 20,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text(
                    "App Update",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  const Text(
                    "A newer version of app is available",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),
                          )
                        : CustomButton(
                            text: "Update Now",
                            onPressed: () async {
                              try {
                                setState(() => _isLoading = true);
                                OtaUpdate().execute(widget.link).listen(
                                  (event) {
                                    showProgressIndicator(value: event.value);
                                  },
                                );
                              } catch (error) {
                                setState(() => _isLoading = false);
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
