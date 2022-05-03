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
  late bool _isLoading, _done;
  late String _progress;
  OtaEvent? event;

  @override
  void initState() {
    super.initState();
    _progress = "";
    _isLoading = _done = false;
  }

  String getText(OtaEvent? event) {
    if (event == null) {
      return "A new version of app is available";
    }
    if (event.status == OtaStatus.DOWNLOADING) {
      return "Downloading $_progress %";
    }
    if (event.status == OtaStatus.DOWNLOAD_ERROR) {
      return "Download failed. Please try again";
    }
    if (event.status == OtaStatus.INSTALLING) {
      return "Installing";
    }
    return "Permission not granted. Please allow permission to install app from external sources.";
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
                  Text(
                    getText(event),
                    style: const TextStyle(
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
                    child: _done
                        ? null
                        : _isLoading
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
                                      (e) {
                                        event = e;
                                        setState(
                                            () => _progress = event!.value!);
                                        if (event!.value != null &&
                                            event!.value == "100") {
                                          setState(() => _done = true);
                                        }
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
