import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelManager {
  static Mixpanel? _instance;

  static Future<Mixpanel> init() async {
    _instance ??= await Mixpanel.init("878b839a6f9c0331bd76a5d9f463d321",
        optOutTrackingDefault: false);
    return _instance!;
  }
}
