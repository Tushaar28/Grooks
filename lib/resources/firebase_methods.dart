import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grooks_dev/constants/constants.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/models/wallet.dart';

class FirebaseMethods {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final CollectionReference usersCollection =
      firestore.collection(USERS_COLLECTION);
  static final CollectionReference categoriesCollection =
      firestore.collection(CATEGORIES_COLLECTION);
  static final CollectionReference feedbackCategoriesCollection =
      firestore.collection(FEEDBACK_CATEGORIES_COLLECTION);
  static final CollectionReference feedbacksCollection =
      firestore.collection(FEEDBACK_COLLECTION);
  static final CollectionReference storesCollection =
      firestore.collection(STORES_COLLECTION);
  static final CollectionReference questionsCollection =
      firestore.collection(QUESTIONS_COLLECTION);
  static final CollectionReference tradesCollection =
      firestore.collection(TRADES_COLLECTION);
  static final CollectionReference settingsCollection =
      firestore.collection(SETTINGS_COLLECTION);
  static final CollectionReference walletsCollection =
      firestore.collection(WALLETS_COLLECTION);

  Future<String> get getRequiredVersion async {
    try {
      String version;
      QuerySnapshot settingSnapshot = await settingsCollection.get();
      version = settingSnapshot.docs.first.get("version");
      return version;
    } catch (error) {
      rethrow;
    }
  }

  Future<String> get getAppLink async {
    try {
      String link;
      QuerySnapshot settingSnapshot = await settingsCollection.get();
      link = settingSnapshot.docs.first.get("apkLink");
      return link;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Category>> get getAllCategories async {
    List<Category> categories = [];
    QuerySnapshot snapshot = await categoriesCollection
        .where('parent', isNull: true)
        .where("isActive", isEqualTo: true)
        .where("isDeleted", isEqualTo: false)
        .get();
    for (var element in snapshot.docs) {
      categories.add(Category.fromMap(element.data() as Map<String, dynamic>));
    }
    return categories;
  }
  
  Future<bool> isNewUser({
    required String mobile,
  }) async {
    try {
      QuerySnapshot userSnapshot =
          await usersCollection.where("mobile", isEqualTo: mobile).get();
      return userSnapshot.size == 0;
    } catch (error) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await signIn(credential);
    } catch (error) {
      rethrow;
    }
  }

  Future<UserCredential> signIn(AuthCredential credential) async {
    UserCredential result = await auth.signInWithCredential(credential);
    return result;
  }

  Future<Users?> getUserDetails({
    String? userId,
  }) async {
    User? currentUser;
    if (userId == null) {
      currentUser = await getCurrentUser();
      if (currentUser == null) return null;
      DocumentSnapshot ds = await usersCollection.doc(currentUser.uid).get();
      if (ds.exists && ds.get('id') != null && ds.get('id').isNotEmpty) {
        return Users.fromMap(ds.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } else {
      DocumentSnapshot ds = await usersCollection.doc(userId).get();
      if (ds.exists) {
        return Users.fromMap(ds.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    }
  }

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = auth.currentUser;
    if (currentUser != null) return currentUser;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<String> uploadPhoto({
    required File image,
    required String id,
    required String folderId,
  }) async {
    try {
      Reference reference = storage.ref().child("$folderId/$id");
      TaskSnapshot snapshot = await reference.putFile(image);
      String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (error) {
      return "";
    }
  }

  Future<Users> getUserDetailsFromReferralCode({
    required String code,
  }) async {
    try {
      QuerySnapshot snapshot =
          await usersCollection.where('referralCode', isEqualTo: code).get();
      Users user =
          Users.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      return user;
    } catch (error) {
      rethrow;
    }
  }

  String generateReferralCode({
    required String userId,
  }) {
    return (userId.split('').reversed.join('')).substring(0, 7);
  }

  Future<void> addUser({
    required String name,
    required String uid,
    String? mobile,
    String? pin,
    File? profilePicture,
    String? referralCode,
    String? profileUrl,
    String? email,
  }) async {
    try {
      String? url = profileUrl;
      Users? referringUser = null;
      DateTime currentDate = DateTime.now();
      if (url != null && url.isNotEmpty && profilePicture != null) {
        url = await uploadPhoto(
            image: profilePicture, id: uid, folderId: "profilePictures");
      }
      if (referralCode != null && referralCode.isNotEmpty) {
        referringUser = await getUserDetailsFromReferralCode(
          code: referralCode,
        );
      }
      String refCode = generateReferralCode(userId: uid);
      Users user = Users(
        name: name,
        mobile: mobile!,
        email: email,
        id: uid,
        createdAt: currentDate,
        image: url,
        lastLoginAt: currentDate,
        referredBy: referringUser != null ? referringUser.id : '',
        referralCode: refCode,
        updatedAt: currentDate,
      );

      await usersCollection.doc(uid).set(user.toMap(user));

      int? welcomeCoins =
          (await settingsCollection.get()).docs.first.get("welcomeCoins");
      int? referralCoins =
          (await settingsCollection.get()).docs.first.get("referralCoins");
      welcomeCoins ??= 500;
      referralCoins ??= 100;

      //Update referring user details
      if (referringUser != null) {
        String docId = usersCollection
            .doc(referringUser.id)
            .collection('referrals')
            .doc()
            .id;
        await usersCollection
            .doc(referringUser.id)
            .collection('referrals')
            .doc(docId)
            .set({
          'id': docId,
          'userId': user.id,
        });
        String walletId = walletsCollection.doc().id;
        Wallet wallet = Wallet(
          bonusCoins: welcomeCoins + referralCoins,
          createdAt: currentDate,
          redeemableCoins: 0,
          userId: uid,
          id: walletId,
          isActive: true,
          isDeleted: false,
          updatedAt: currentDate,
        );
        await walletsCollection.doc(walletId).set(wallet.toMap(wallet));
      } else {
        String walletId = walletsCollection.doc().id;
        Wallet wallet = Wallet(
          bonusCoins: welcomeCoins,
          createdAt: currentDate,
          redeemableCoins: 0,
          userId: uid,
          id: walletId,
          isActive: true,
          isDeleted: false,
          updatedAt: currentDate,
        );
        await walletsCollection.doc(walletId).set(wallet.toMap(wallet));
      }
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> saveDeviceToken(String? fcmToke) async {
    User? currentUser = await getCurrentUser();

    if (currentUser != null && fcmToke != null) {
      var tokenRef = usersCollection
          .doc(currentUser.uid)
          .collection('tokens')
          .doc(fcmToke);
      await tokenRef.set({
        'token': fcmToke,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  Future<void> saveReferalLink(String? link) async {
    User? currentUser = await getCurrentUser();

    if (currentUser != null && link != null && link.isNotEmpty) {
      await usersCollection.doc(currentUser.uid).update({
        'referralCode': link,
      });
    }
  }

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      String? profileUrl;
      if (data.containsKey('profilePicture')) {
        profileUrl = await uploadPhoto(
            image: data['profilePicture'],
            id: userId,
            folderId: "profilePictures");
      }
      if (profileUrl != null) data['profilePicture'] = profileUrl;
      await usersCollection.doc(userId).update(data);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<int> getUserBonusCoins({
    required String userId,
  }) async {
    try {
      int coins;
      QuerySnapshot snapshot =
          await walletsCollection.where('userId', isEqualTo: userId).get();
      coins = snapshot.docs.first.get('bonusCoins');
      return coins;
    } catch (error) {
      rethrow;
    }
  }

  Future<int> getUserRedeemableCoins({
    required String userId,
  }) async {
    try {
      int coins;
      QuerySnapshot snapshot =
          await walletsCollection.where('userId', isEqualTo: userId).get();
      coins = snapshot.docs.first.get('redeemableCoins');
      return coins;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> getUserActiveStatus({
    String? userId,
  }) async {
    try {
      Users user;
      if (userId != null && userId.isNotEmpty) {
        user = (await getUserDetails(userId: userId))!;
      } else {
        user = (await getUserDetails())!;
      }
      return user.isActive;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Category>> getSubcategoriesFromCategory({
    required String categoryId,
  }) async {
    try {
      List<Category> subcategories = [];
      QuerySnapshot subcategoriesSnapshot = await categoriesCollection
          .where('parent', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .get();
      for (var element in subcategoriesSnapshot.docs) {
        subcategories
            .add(Category.fromMap(element.data() as Map<String, dynamic>));
      }
      return subcategories;
    } catch (error) {
      throw error.toString();
    }
  }
}
