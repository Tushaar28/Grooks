import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_methods.dart';

class FirebaseRepository {
  static final FirebaseRepository _repository = FirebaseRepository();

  factory FirebaseRepository() {
    return _repository;
  }

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
}
