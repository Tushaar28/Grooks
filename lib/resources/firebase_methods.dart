import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grooks_dev/constants/constants.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/feedback.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/models/transaction.dart';
import 'package:grooks_dev/models/transfer.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/models/wallet.dart';
import 'package:grooks_dev/models/withdrawl.dart';
import '../models/transaction.dart' as model;

class FirebaseMethods {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final FirebaseMessaging _messaging;
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
  static final CollectionReference withdrawlsCollection =
      firestore.collection(WITHDRAWLS_COLLECTION);

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

    categories.sort((a, b) => a.priority.compareTo(b.priority));
    return categories;
  }

  Future<double> get getCoinsTransferCommission async {
    try {
      double commission;
      QuerySnapshot qs = await settingsCollection.get();
      commission = qs.docs.first.get('transferCommission').toDouble();
      return commission;
    } catch (error) {
      rethrow;
    }
  }

  Future<QuerySnapshot> get getFeedbackCategories async {
    QuerySnapshot data = await feedbackCategoriesCollection.get();
    return data;
  }

  Future<Map<String, dynamic>> get getMaintenanceStatus async {
    try {
      Map<String, dynamic> map = {};
      QuerySnapshot qs = await settingsCollection.get();
      String docId = qs.docs.first.id;
      map['status'] = qs.docs.first.get('isUnderMaintenance');
      map['message'] = qs.docs.first.get('maintenanceMessage');
      if (map.containsKey('status') && map['status'] == true) {
        await settingsCollection.doc(docId).update({
          'lastMaintenanceAt': DateTime.now(),
        });
      }
      return map;
    } catch (error) {
      rethrow;
    }
  }

  Future<String> get getPackageName async {
    String package =
        (await settingsCollection.get()).docs.first.get("packageName");
    return package;
  }

  Future<String> get getUrlPrefix async {
    String prefix =
        (await settingsCollection.get()).docs.first.get("referralUrlPrefix");
    return prefix;
  }

  Future<String> get getReferralFallbackUrl async {
    String url =
        (await settingsCollection.get()).docs.first.get("referralFallbackUrl");
    return url;
  }

  Future<double> get getPaymentGatewayCommission async {
    try {
      QuerySnapshot qs = await settingsCollection.get();
      double? commission = qs.docs.first.get("paymentGatewayCommission");
      if (commission == null) throw "An error occured";
      return commission;
    } catch (error) {
      throw error.toString();
    }
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
      if (profilePicture != null) {
        url = await uploadPhoto(
            image: profilePicture, id: uid, folderId: "profilePictures");
      }
      if (referralCode != null && referralCode.isNotEmpty) {
        referringUser = await getUserDetailsFromReferralCode(
          code: referralCode,
        );
      }
      String refCode = generateReferralCode(userId: uid);
      String? token = await _messaging.getToken();
      Users user = Users(
        name: name,
        mobile: mobile,
        email: email,
        id: uid,
        createdAt: currentDate,
        image: url,
        lastLoginAt: currentDate,
        referredBy: referringUser?.id,
        referralCode: refCode,
        updatedAt: currentDate,
      );

      await usersCollection.doc(uid).set(user.toMap(user));
      await saveDeviceToken(token);

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
        QuerySnapshot refferingUserWalletSnapshot = await walletsCollection
            .where('userId', isEqualTo: referringUser.id)
            .get();
        int referringUserCurrrentBonusCoins =
            refferingUserWalletSnapshot.docs.first.get('bonusCoins');
        String referringUserWalletId =
            refferingUserWalletSnapshot.docs.first.id;
        await walletsCollection.doc(referringUserWalletId).update(
            {'bonusCoins': referringUserCurrrentBonusCoins + referralCoins});
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
      if (data.containsKey('image')) {
        profileUrl = await uploadPhoto(
            image: data['image'], id: userId, folderId: "image");
      }
      if (profileUrl != null) data['image'] = profileUrl;
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
      Users? user;
      if (userId != null && userId.isNotEmpty) {
        user = (await getUserDetails(userId: userId))!;
      } else {
        user = await getUserDetails();
      }
      return user?.isActive ?? true;
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

  Future<List<Question>> getOpenQuestions({
    required String subcategoryId,
  }) async {
    try {
      List<Question> questions = [];
      QuerySnapshot questionsSnapshot = await questionsCollection
          .where('parent', isEqualTo: subcategoryId)
          .where("answer", isNull: true)
          .where("closedAt", isNull: true)
          .where("isActive", isEqualTo: true)
          .where("isDeleted", isEqualTo: false)
          .get();

      for (var element in questionsSnapshot.docs) {
        if (element.exists) {
          questions
              .add(Question.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      return questions;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Question>> getClosedQuestions({
    required String subcategoryId,
  }) async {
    try {
      List<Question> questions = [];
      QuerySnapshot snapshot = await questionsCollection
          .where('parent', isEqualTo: subcategoryId)
          .where('answer', whereIn: [true, false])
          .where("isActive", isEqualTo: false)
          .get();
      for (var element in snapshot.docs) {
        if (element.exists) {
          questions
              .add(Question.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      return questions;
    } catch (error) {
      rethrow;
    }
  }

  Future<Question> getQuestionDetails({
    required String questionId,
  }) async {
    try {
      Question question;
      QuerySnapshot snapshot =
          await questionsCollection.where('id', isEqualTo: questionId).get();
      question =
          Question.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      return question;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> getQuestionActiveStatus({
    required String questionId,
  }) async {
    try {
      bool isQuestionActive =
          (await questionsCollection.doc(questionId).get()).get('isActive');
      return isQuestionActive;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> placeTrade({
    required String userId,
    required bool response,
    required String questionId,
    required int bonusCoins,
    required int redeemableCoins,
    required int count,
    required int bet,
  }) async {
    try {
      if (bet > bonusCoins + redeemableCoins) throw "Insufficient coins";
      QuerySnapshot walletSnapshot =
          await walletsCollection.where('userId', isEqualTo: userId).get();
      bool isQuestionActive =
          (await questionsCollection.doc(questionId).get()).get('isActive');
      if (isQuestionActive == false) throw "An error occured";
      String walletId = walletSnapshot.docs.first.id;
      DateTime currentDate = DateTime.now();
      List<Trade> trades = [];
      List<String> tradeIds = [];
      //List<model.Transaction> transactions = [];
      int bonusCoinsUsed, redeemableCoinsUsed;
      for (int i = 0; i < count; i++) {
        int remainingExpense = bet;
        bonusCoinsUsed = 0;
        redeemableCoinsUsed = 0;
        if (bonusCoins > 0) {
          bool isBetTotallyFilledByBonus = (bonusCoins - bet >= 0);
          bonusCoinsUsed = isBetTotallyFilledByBonus ? bet : bonusCoins;
          remainingExpense =
              isBetTotallyFilledByBonus ? 0 : remainingExpense - bonusCoins;
          bonusCoins = isBetTotallyFilledByBonus ? bonusCoins - bet : 0;
        }
        if (remainingExpense > 0) {
          redeemableCoins -= remainingExpense;
          redeemableCoinsUsed = remainingExpense;
        }
        String tradeId = tradesCollection.doc().id;
        Trade trade = Trade(
          id: tradeId,
          bonusCoinsUsed: bonusCoinsUsed,
          redeemableCoinsUsed: redeemableCoinsUsed,
          coins: bet,
          createdAt: currentDate,
          questionId: questionId,
          response: response,
          status: Status.ACTIVE_UNPAIRED,
          userId: userId,
          updatedAt: currentDate,
        );
        trades.add(trade);
        tradeIds.add(tradeId);

        // String transactionId =
        //     walletsCollection.doc(walletId).collection('transactions').doc().id;
        // model.Transaction transaction = model.Transaction(
        //   id: transactionId,
        //   createdAt: currentDate,
        //   status: model.TransactionStatus.PROCESSED,
        //   amount: bet.toDouble(),
        //   updatedAt: currentDate,
        // );
        // transactions.add(transaction);
      }

      //Add to database
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot questionSnapshot =
            await questionsCollection.doc(questionId).get();

        int currentOpenBets = questionSnapshot.get("openTradesCount");

        //Update coins of user
        await walletsCollection.doc(walletId).update({
          'bonusCoins': bonusCoins,
          'redeemableCoins': redeemableCoins,
          'updatedAt': currentDate,
        });

        // for (int i = 0; i < transactions.length; i++) {
        //   walletsCollection
        //       .doc(walletId)
        //       .collection('transactions')
        //       .doc(transactions[i].id)
        //       .set(transactions[i].toMap(transactions[i])
        //           as Map<String, dynamic>);
        // }

        await usersCollection.doc(userId).update({
          'questions': FieldValue.arrayUnion([questionId]),
        });

        //Add list of trades in questions collection
        if (response) {
          await questionsCollection.doc(questionId).update({
            'yesTrades': FieldValue.arrayUnion(tradeIds),
            'openTradesCount': currentOpenBets + count,
            'updatedAt': currentDate,
          });
        } else {
          await questionsCollection.doc(questionId).update({
            'noTrades': FieldValue.arrayUnion(tradeIds),
            'openTradesCount': currentOpenBets + count,
            'updatedAt': currentDate,
          });
        }

        //Add trade document in trades colelction
        for (int i = 0; i < trades.length; i++) {
          await tradesCollection
              .doc(trades[i].id)
              .set(trades[i].toMap(trades[i]));
        }
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<QuerySnapshot> getTopTrades({
    required String userId,
    required String questionId,
  }) async {
    try {
      QuerySnapshot data = await tradesCollection
          .where('questionId', isEqualTo: questionId)
          .where('status',
              isEqualTo: Status.ACTIVE_UNPAIRED.toString().split('.').last)
          .where('userId', isNotEqualTo: userId)
          .orderBy('userId')
          .orderBy('createdAt', descending: true)
          .get();
      return data;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Trade>> getTradesForQuestionForUser({
    required String userId,
    required String questionId,
  }) async {
    try {
      List<Trade> trades = [];
      QuerySnapshot data = await tradesCollection
          .where('questionId', isEqualTo: questionId)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      for (var element in data.docs) {
        trades.add(Trade.fromMap(element.data() as Map<String, dynamic>));
      }
      return trades;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> cancelTrade({
    required Trade trade,
    required String userId,
  }) async {
    try {
      bool isQuestionActive =
          (await questionsCollection.doc(trade.questionId).get())
              .get('isActive');
      if (isQuestionActive == false) throw "An error occured";
      if (trade.status != Status.ACTIVE_UNPAIRED) {
        throw "An error occured";
      }
      await firestore.runTransaction((transaction) async {
        QuerySnapshot walletSnapshot =
            await walletsCollection.where('userId', isEqualTo: userId).get();
        DocumentSnapshot questionSnapshot =
            await questionsCollection.doc(trade.questionId).get();
        int currentOpenBets = questionSnapshot.get("openTradesCount");
        String walletId = walletSnapshot.docs.first.id;
        int currentBonusCoins = await getUserBonusCoins(userId: userId);
        int currentRedeemableCoins =
            await getUserRedeemableCoins(userId: userId);
        int bonusCoinsUsed = trade.bonusCoinsUsed;
        int redeemableCoinsUsed = trade.redeemableCoinsUsed;
        DateTime currentDate = DateTime.now();

        if (trade.response) {
          await questionsCollection.doc(trade.questionId).update({
            'yesTrades': FieldValue.arrayRemove([trade.id]),
            'openTradesCount': currentOpenBets - 1,
            'updatedAt': currentDate,
          });
        } else {
          await questionsCollection.doc(trade.questionId).update({
            'noTrades': FieldValue.arrayUnion([trade.id]),
            'openTradesCount': currentOpenBets - 1,
            'updatedAt': currentDate,
          });
        }

        await walletsCollection.doc(walletId).update({
          'updatedAt': currentDate,
          'bonusCoins': currentBonusCoins + bonusCoinsUsed,
          'redeemableCoins': currentRedeemableCoins + redeemableCoinsUsed,
        });

        // await walletsCollection
        //     .doc(walletId)
        //     .collection('transactions')
        //     .doc(transactionId)
        //     .set(transaction.toMap(transaction) as Map<String, dynamic>);

        await tradesCollection.doc(trade.id).update({
          'status': Status.CANCELLED_BY_USER.toString().split('.').last,
          'cancelledAt': currentDate,
          'updatedAt': currentDate,
        });
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> pairTrade({
    required Trade firstTrade,
    required String userId,
  }) async {
    try {
      bool isQuestionActive =
          (await questionsCollection.doc(firstTrade.questionId).get())
              .get('isActive');
      if (isQuestionActive == false) throw "An error occured";
      if (firstTrade.status == Status.ACTIVE_PAIRED) {
        throw 'Trade is already paired';
      }
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot questionSnapshot =
            await questionsCollection.doc(firstTrade.questionId).get();

        QuerySnapshot walletSnapshot =
            await walletsCollection.where('userId', isEqualTo: userId).get();
        String walletId = walletSnapshot.docs.first.id;
        int currentBonusCoins = await getUserBonusCoins(userId: userId);
        int currentRedeemableCoins =
            await getUserRedeemableCoins(userId: userId);
        int bet = 100 - firstTrade.coins;
        if (bet > currentBonusCoins + currentRedeemableCoins) {
          throw "Insufficient coins";
        }
        int bonusCoinsUsed = min(currentBonusCoins, bet);
        int redeemableCoinsUsed =
            bet > currentBonusCoins ? bet - currentBonusCoins : 0;
        int currentOpenBets = questionSnapshot.get("openTradesCount");
        int currentPairedBets = questionSnapshot.get("pairedTradesCount");
        String tradeId = tradesCollection.doc().id;
        DateTime pairedDateTime = DateTime.now();
        Trade trade = Trade(
          id: tradeId,
          bonusCoinsUsed: bonusCoinsUsed,
          redeemableCoinsUsed: redeemableCoinsUsed,
          coins: bet,
          createdAt: DateTime.now(),
          questionId: firstTrade.questionId,
          response: !firstTrade.response,
          status: Status.ACTIVE_PAIRED,
          userId: userId,
          pairedAt: pairedDateTime,
          pairedTradeId: firstTrade.id,
          updatedAt: pairedDateTime,
        );
        await tradesCollection.doc(tradeId).set(trade.toMap(trade));
        await tradesCollection.doc(firstTrade.id).update({
          'status': Status.ACTIVE_PAIRED.toString().split('.').last,
          'pairedAt': pairedDateTime,
          'updatedAt': DateTime.now(),
          'pairedTradeId': firstTrade.id,
        });

        // String transactionId =
        //     walletsCollection.doc(walletId).collection('transactions').doc().id;
        // model.Transaction transaction = model.Transaction(
        //   id: transactionId,
        //   createdAt: DateTime.now(),
        //   status: model.TransactionStatus.PROCESSED,
        //   type: TransactionType.COINS_LOST,
        //   amount: bet.toDouble(),
        //   bonusCoins: bonusCoinsUsed,
        //   redeemableCoins: redeemableCoinsUsed,
        //   updatedAt: DateTime.now(),
        // );
        // await walletsCollection
        //     .doc(walletId)
        //     .collection('transactions')
        //     .doc(transactionId)
        //     .set(transaction.toMap(transaction) as Map<String, dynamic>);

        await walletsCollection.doc(walletId).update({
          'updatedAt': DateTime.now(),
          'bonusCoins': currentBonusCoins - bonusCoinsUsed,
          'redeemableCoins': currentRedeemableCoins - redeemableCoinsUsed,
        });

        await usersCollection.doc(userId).update({
          'questions': FieldValue.arrayUnion([firstTrade.questionId])
        });

        if (firstTrade.response == false) {
          await questionsCollection.doc(firstTrade.questionId).update({
            'yesTrades': FieldValue.arrayUnion([trade.id]),
            'openTradesCount': currentOpenBets - 1,
            'pairedTradesCount': currentPairedBets + 1,
            'lastTradedPrice': bet,
            'updatedAt': pairedDateTime,
          });
        } else {
          await questionsCollection.doc(firstTrade.questionId).update({
            'noTrades': FieldValue.arrayUnion([trade.id]),
            'openTradesCount': currentOpenBets - 1,
            'pairedTradesCount': currentPairedBets + 1,
            'lastTradedPrice': firstTrade.coins,
            'updatedAt': pairedDateTime,
          });
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getUserNameFromUserId({
    required String userId,
  }) async {
    try {
      String name;
      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
      name = userSnapshot.get('name');
      return name;
    } catch (error) {
      rethrow;
    }
  }

  Future<Users?> verifyMobileNumberOrEmail({
    required String value,
  }) async {
    try {
      Users user;
      Pattern mobilePattern = r'^[6789]\d{9}$';
      RegExp mobileRegex = RegExp(mobilePattern.toString());
      if (mobileRegex.hasMatch(value)) {
        value = "+91" + value;
        QuerySnapshot snapshot =
            await usersCollection.where('mobile', isEqualTo: value).get();
        if (snapshot.docs.isEmpty) return null;
        user =
            Users.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        QuerySnapshot snapshot =
            await usersCollection.where('email', isEqualTo: value).get();
        if (snapshot.size == 0) return null;
        user =
            Users.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return user;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> transferCoins({
    required String senderId,
    required String receiverId,
    required int deductCoins,
    required int transferCoins,
  }) async {
    try {
      await firestore.runTransaction(
        (transaction) async {
          QuerySnapshot walletSnapshot = await walletsCollection
              .where('userId', isEqualTo: senderId)
              .get();
          String walletId = walletSnapshot.docs.first.id;
          int currentRedeemableCoins =
              (await walletsCollection.doc(walletId).get())
                  .get("redeemableCoins");
          if (deductCoins > currentRedeemableCoins) {
            throw "Insufficient coins";
          }
          DateTime currentDate = DateTime.now();
          int senderCurrentRedeemableCoins =
              await getUserRedeemableCoins(userId: senderId);
          int receiverCurrentBonusCoins =
              await getUserBonusCoins(userId: receiverId);

          //Deduct redeemable coins from sender

          String docId =
              walletsCollection.doc(walletId).collection('transfers').doc().id;
          Transfer transfer = Transfer(
            id: docId,
            coins: deductCoins,
            createdAt: currentDate,
            updatedAt: currentDate,
            isSuccess: true,
            receiverId: receiverId,
            senderId: senderId,
          );
          // model.Transaction transaction = model.Transaction(
          //   id: docId,
          //   createdAt: currentDate,
          //   type: TransactionType.COINS_SENT,
          //   receiverId: receiverId,
          //   redeemableCoins: deductCoins,
          //   status: model.TransactionStatus.PROCESSED,
          //   updatedAt: currentDate,
          // );

          await walletsCollection.doc(walletId).update({
            'redeemableCoins': senderCurrentRedeemableCoins - deductCoins,
            'updatedAt': currentDate,
          });

          await walletsCollection
              .doc(walletId)
              .collection('transfers')
              .doc(docId)
              .set(transfer.toMap(transfer) as Map<String, dynamic>);

          // Add bonus coins to receiver
          walletSnapshot = await walletsCollection
              .where('userId', isEqualTo: receiverId)
              .get();
          walletId = walletSnapshot.docs.first.id;
          docId =
              walletsCollection.doc(walletId).collection('transfers').doc().id;
          transfer = Transfer(
            id: docId,
            createdAt: currentDate,
            updatedAt: currentDate,
            coins: transferCoins,
            isSuccess: true,
            receiverId: receiverId,
            senderId: senderId,
          );
          // transaction = model.Transaction(
          //   id: docId,
          //   createdAt: DateTime.now(),
          //   type: model.TransactionType.COINS_RECEIVED,
          //   senderId: senderId,
          //   bonusCoins: transferCoins,
          //   status: model.TransactionStatus.PROCESSED,
          //   updatedAt: currentDate,
          // );

          await walletsCollection.doc(walletId).update({
            'bonusCoins': receiverCurrentBonusCoins + transferCoins,
            'updatedAt': currentDate,
          });

          await walletsCollection
              .doc(walletId)
              .collection('transfers')
              .doc(docId)
              .set(transfer.toMap(transfer) as Map<String, dynamic>);
        },
        timeout: const Duration(seconds: 15),
      );
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getUserTradeActivities({
    required String userId,
    DateTime? lastTradeDate,
    String? lastTradeId,
    int? pageSize,
  }) async {
    try {
      List<Map<String, dynamic>> data = [];
      QuerySnapshot tradesSnapshot;
      List<QueryDocumentSnapshot> snapshotList = [];
      if (lastTradeId != null) {
        tradesSnapshot = await tradesCollection
            .where('userId', isEqualTo: userId)
            .orderBy('updatedAt', descending: true)
            .orderBy('id', descending: true)
            .startAfter([lastTradeDate, lastTradeId])
            .limit(pageSize!)
            .get();
      } else {
        tradesSnapshot = await tradesCollection
            .where('userId', isEqualTo: userId)
            .orderBy('updatedAt', descending: true)
            .orderBy('id', descending: true)
            .limit(pageSize!)
            .get();
      }
      for (var element in tradesSnapshot.docs) {
        snapshotList.add(element);
      }
      await Future.forEach(snapshotList, (QueryDocumentSnapshot element) async {
        Trade trade = Trade.fromMap(element.data() as Map<String, dynamic>);
        Question question =
            await getQuestionDetails(questionId: trade.questionId);
        data.add({
          'question': question,
          'trade': trade,
        });
      });
      return data;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransferActivities({
    required String userId,
    DateTime? lastTradeDate,
    String? lastTradeId,
    int? pageSize,
  }) async {
    try {
      List<Map<String, dynamic>> data = [];
      List<QueryDocumentSnapshot> snapshotList = [];
      QuerySnapshot walletSnapshot =
          await walletsCollection.where('userId', isEqualTo: userId).get();
      String walletId = walletSnapshot.docs.first.id;
      QuerySnapshot transfersSnapshot;
      if (lastTradeDate != null &&
          lastTradeId != null &&
          lastTradeId.isNotEmpty) {
        transfersSnapshot = await walletsCollection
            .doc(walletId)
            .collection('transfers')
            .orderBy('updatedAt', descending: true)
            .orderBy('id', descending: true)
            .startAfter([lastTradeDate, lastTradeId])
            .limit(pageSize!)
            .get();
      } else {
        transfersSnapshot = await walletsCollection
            .doc(walletId)
            .collection('transfers')
            .orderBy('updatedAt', descending: true)
            .orderBy('id', descending: true)
            .limit(pageSize!)
            .get();
      }
      for (var element in transfersSnapshot.docs) {
        snapshotList.add(element);
      }
      await Future.forEach(snapshotList, (QueryDocumentSnapshot element) async {
        Transfer transfer =
            Transfer.fromMap(element.data() as Map<String, dynamic>);
        Users user;
        if (transfer.receiverId != null) {
          user = (await getUserDetails(userId: transfer.receiverId))!;
        } else {
          user = (await getUserDetails(userId: transfer.senderId))!;
        }
        data.add({
          'user': user,
          'transfer': transfer,
        });
      });

      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> sendFeedback({
    required String category,
    required String subject,
    required String description,
    required Users user,
    File? image,
  }) async {
    try {
      String docId = feedbacksCollection.doc().id;
      String? url;
      if (image != null) {
        url = await uploadPhoto(
          image: image,
          id: docId,
          folderId: "feedbacks",
        );
      }
      Feedback feedback = Feedback(
        category: category,
        createdAt: DateTime.now(),
        description: description,
        id: docId,
        subject: subject,
        userId: user.id,
        image: url,
      );
      await feedbacksCollection.doc(docId).set(feedback.toMap(feedback));
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<Trade>> getOpenTradesForUser({
    required String userId,
  }) async {
    try {
      List<Trade> openTrades = [];
      QuerySnapshot tradesSnapshot = await tradesCollection
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [
            Status.ACTIVE_PAIRED.toString().split('.').last,
            Status.ACTIVE_UNPAIRED.toString().split('.').last
          ])
          .orderBy('updatedAt', descending: true)
          .get();
      for (var trade in tradesSnapshot.docs) {
        openTrades.add(Trade.fromMap(trade.data() as Map<String, dynamic>));
      }

      return openTrades;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<String> getSubcategoryNameForQuestion({
    required String questionId,
  }) async {
    try {
      String name;
      DocumentSnapshot questionSnapshot =
          await questionsCollection.doc(questionId).get();
      String categoryId = questionSnapshot.get('parent');
      QuerySnapshot categorySnapshot =
          await categoriesCollection.where('id', isEqualTo: categoryId).get();
      name = categorySnapshot.docs.first.get('name');
      return name;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Trade>> getClosedTradesForUser({
    required String userId,
  }) async {
    try {
      List<Trade> openTrades = [];
      QuerySnapshot tradesSnapshot = await tradesCollection
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [
            Status.LOST.toString().split('.').last,
            Status.WON.toString().split('.').last
          ])
          .orderBy('updatedAt', descending: true)
          .get();
      for (var trade in tradesSnapshot.docs) {
        openTrades.add(Trade.fromMap(trade.data() as Map<String, dynamic>));
      }
      return openTrades;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTransactionDetails({
    required bool transactionStatus,
    required String transactionId,
    required String userId,
    required double amount,
    required int coins,
  }) async {
    try {
      DateTime currentDate = DateTime.now();
      String walletId =
          (await walletsCollection.where("userId", isEqualTo: userId).get())
              .docs
              .first
              .id;
      String id =
          walletsCollection.doc(walletId).collection("transactions").doc().id;
      model.Transaction transaction = model.Transaction(
        id: id,
        createdAt: currentDate,
        updatedAt: currentDate,
        status: transactionStatus
            ? TransactionStatus.PROCESSED
            : TransactionStatus.FAILED,
        amount: amount,
        transactionId: transactionId,
        coins: coins,
      );

      if (transactionStatus) {
        int currentBonusCoins =
            (await walletsCollection.doc(walletId).get()).get("bonusCoins");
        await walletsCollection.doc(walletId).update({
          'bonusCoins': coins + currentBonusCoins,
          'updatedAt': currentDate,
        });
      }
      await walletsCollection
          .doc(walletId)
          .collection("transactions")
          .doc(id)
          .set(transaction.toMap(transaction) as Map<String, dynamic>);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<bool> getPanVerificationStatus({
    required String userId,
  }) async {
    try {
      bool status =
          (await usersCollection.doc(userId).get()).get("isPanVerified");
      return status;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> sendWithdrawlRequest({
    required String userId,
    required double amount,
    String? upi,
    String? accountNumber,
    String? ifscCode,
  }) async {
    try {
      String docId = withdrawlsCollection.doc().id;
      DateTime currentDate = DateTime.now();
      late final Withdrawl withdrawl;
      if (upi != null && upi.isNotEmpty) {
        withdrawl = Withdrawl(
          id: docId,
          userId: userId,
          amount: amount,
          createdAt: currentDate,
          updatedAt: currentDate,
          status: WithdrawlStatus.INITIATED,
          upi: upi,
        );
      } else {
        withdrawl = Withdrawl(
          id: docId,
          userId: userId,
          amount: amount,
          createdAt: currentDate,
          updatedAt: currentDate,
          status: WithdrawlStatus.INITIATED,
          accountNumber: accountNumber,
          ifscCode: ifscCode,
        );
      }
      await withdrawlsCollection.doc(docId).set(withdrawl.toMap(withdrawl));
    } catch (error) {
      rethrow;
    }
  }

  Future<String> getUserReferralCode({
    required String userId,
  }) async {
    try {
      String code =
          (await usersCollection.doc(userId).get()).get("referralCode");
      return code;
    } catch (error) {
      rethrow;
    }
  }
}
