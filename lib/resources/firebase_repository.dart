import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_methods.dart';

class FirebaseRepository {
  final FirebaseMethods firebaseMethods = FirebaseMethods();

  Future<String> get getRequiredVersion => firebaseMethods.getRequiredVersion;

  Future<String> get getAppLink => firebaseMethods.getAppLink;

  Future<bool> isNewUser({
    required String mobile,
  }) =>
      firebaseMethods.isNewUser(mobile: mobile);

  Future<UserCredential> signInWithGoogle() =>
      firebaseMethods.signInWithGoogle();

  Future<Users?> getUserDetails({
    String? userId,
  }) =>
      firebaseMethods.getUserDetails(userId: userId);

  Future<void> signOut() => firebaseMethods.signOut();

  Future<void> addUser({
    required String name,
    required String uid,
    String? mobile,
    File? profilePicture,
    String? referralCode,
    String? profileUrl,
    String? email,
  }) =>
      firebaseMethods.addUser(
        name: name,
        mobile: mobile,
        uid: uid,
        profilePicture: profilePicture,
        referralCode: referralCode,
        profileUrl: profileUrl,
        email: email,
      );

  Future<void> saveDeviceToken(fcmToke) =>
      firebaseMethods.saveDeviceToken(fcmToke);

  Future<void> saveReferalLink(link) => firebaseMethods.saveReferalLink(link);

  Future<UserCredential> signIn(AuthCredential credential) =>
      firebaseMethods.signIn(credential);

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) =>
      firebaseMethods.updateUser(
        userId: userId,
        data: data,
      );

  Future<int> getUserBonusCoins({
    required String userId,
  }) =>
      firebaseMethods.getUserBonusCoins(userId: userId);

  Future<int> getUserRedeemableCoins({
    required String userId,
  }) =>
      firebaseMethods.getUserRedeemableCoins(userId: userId);

  Future<bool> getUserActiveStatus({
    String? userId,
  }) =>
      firebaseMethods.getUserActiveStatus(userId: userId);
}
