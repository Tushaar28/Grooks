import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const AutoSizeText("App update"),
      content: const AutoSizeText("A new version of app is available"),
      actions: [
        Center(
          child: _isLoading
              ? const CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                )
              : TextButton(
                  child: const AutoSizeText("Update now"),
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    OtaUpdate().execute(widget.link).listen(
                      (event) {
                        showProgressIndicator(value: event.value);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
