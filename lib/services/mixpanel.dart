import 'package:grooks_dev/resources/firebase_repository.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelManager {
  static Mixpanel? _instance;
  static final FirebaseRepository _repository = FirebaseRepository();

  static Future<String> _getMixpanelToken() async {
    return await _repository.getMixpanelToken;
  }

  static Future<Mixpanel> init() async {
    String token = await _getMixpanelToken();
    _instance ??= await Mixpanel.init(token, optOutTrackingDefault: false);
    return _instance!;
  }
}
