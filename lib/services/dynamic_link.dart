import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/resources/firebase_repository.dart';
import 'auth.dart';

class DynamicLinkApi {
  final FirebaseDynamicLinks _dynamicLink = FirebaseDynamicLinks.instance;
  final FirebaseRepository _repository = FirebaseRepository();

  final String _urlPrefix = "https://bagoyo.page.link";

  Future<String> createReferralLink(String referralCode) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: _urlPrefix,
      link: Uri.parse('$_urlPrefix/refer?code=$referralCode'),
      androidParameters: const AndroidParameters(
        packageName: 'com.bagoyo.grooks_dev',
      ),
      socialMetaTagParameters: const SocialMetaTagParameters(
        title: 'Refer A Friend',
        description: 'Refer and earn',
      ),
    );

    final ShortDynamicLink shortLink =
        await _dynamicLink.buildShortLink(dynamicLinkParameters);

    final Uri dynamicUrl = shortLink.shortUrl;
    return dynamicUrl.toString();
  }

  Future<void> handleDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData? data = await _dynamicLink.getInitialLink();
    _dynamicLink.onLink
        .listen((data) => handleSuccessLinking(data, context))
        .onError((error) => print("ERROR = $error"));
    handleSuccessLinking(data, context);
  }

  Future<void> handleSuccessLinking(
      PendingDynamicLinkData? data, BuildContext context) async {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      bool isReferred = deepLink.pathSegments.contains('refer');
      if (isReferred) {
        String? code = deepLink.queryParameters['code'];
        if (code != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Auth(referralCode: code),
            ),
          );
        }
      }
    }
  }
}
