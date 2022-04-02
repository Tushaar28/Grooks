import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grooks_dev/models/category.dart';
import 'package:grooks_dev/models/payout.dart';
import 'package:grooks_dev/models/question.dart';
import 'package:grooks_dev/models/trade.dart';
import 'package:grooks_dev/models/user.dart';
import 'package:grooks_dev/resources/firebase_methods.dart';
import '../models/transaction.dart' as model;

class FirebaseRepository {
  final FirebaseMethods firebaseMethods = FirebaseMethods();

  Future<String> get getRequiredVersion => firebaseMethods.getRequiredVersion;

  Future<String> get getAppLink => firebaseMethods.getAppLink;

  Future<List<Category>> get getAllCategories =>
      firebaseMethods.getAllCategories;

  Future<double> get getCoinsTransferCommission =>
      firebaseMethods.getCoinsTransferCommission;

  Future<QuerySnapshot> get getFeedbackCategories =>
      firebaseMethods.getFeedbackCategories;

  Future<Map<String, dynamic>> get getMaintenanceStatus =>
      firebaseMethods.getMaintenanceStatus;

  Future<String> get getPackageName => firebaseMethods.getPackageName;

  Future<String> get getUrlPrefix => firebaseMethods.getUrlPrefix;

  Future<String> get getReferralFallbackUrl =>
      firebaseMethods.getReferralFallbackUrl;

  Future<double> get getPaymentGatewayCommission =>
      firebaseMethods.getPaymentGatewayCommission;

  Future<double> get getWinCommission => firebaseMethods.getWinCommission;

  Future<double> get getPayoutCommission => firebaseMethods.getPayoutCommission;

  Future<String> get getMixpanelToken => firebaseMethods.getMixpanelToken;

  Future<int> get getUserReferralCoins => firebaseMethods.getUserReferralCoins;

  Future<String> get getUserReferralMessage =>
      firebaseMethods.getUserReferralMessage;

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
    String? password,
  }) =>
      firebaseMethods.addUser(
        name: name,
        mobile: mobile,
        uid: uid,
        profilePicture: profilePicture,
        referralCode: referralCode,
        profileUrl: profileUrl,
        email: email,
        password: password,
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

  Future<List<Category>> getSubcategoriesFromCategory({
    required String categoryId,
  }) =>
      firebaseMethods.getSubcategoriesFromCategory(categoryId: categoryId);

  Future<List<Question>> getOpenQuestions({
    required String subcategoryId,
  }) =>
      firebaseMethods.getOpenQuestions(subcategoryId: subcategoryId);

  Future<List<Question>> getClosedQuestions({
    required String subcategoryId,
  }) =>
      firebaseMethods.getClosedQuestions(subcategoryId: subcategoryId);

  Future<Question> getQuestionDetails({
    required String questionId,
  }) =>
      firebaseMethods.getQuestionDetails(questionId: questionId);

  Future<void> placeTrade({
    required int bet,
    required int bonusCoins,
    required int redeemableCoins,
    required int count,
    required String questionId,
    required bool response,
    required String userId,
  }) =>
      firebaseMethods.placeTrade(
        bet: bet,
        bonusCoins: bonusCoins,
        count: count,
        questionId: questionId,
        redeemableCoins: redeemableCoins,
        response: response,
        userId: userId,
      );

  Future<QuerySnapshot> getTopTrades({
    required String userId,
    required String questionId,
  }) =>
      firebaseMethods.getTopTrades(
        userId: userId,
        questionId: questionId,
      );

  Future<List<Trade>> getTradesForQuestionForUser({
    required String userId,
    required String questionId,
  }) =>
      firebaseMethods.getTradesForQuestionForUser(
        questionId: questionId,
        userId: userId,
      );

  Future<void> cancelTrade({
    required Trade trade,
    required String userId,
  }) =>
      firebaseMethods.cancelTrade(
        trade: trade,
        userId: userId,
      );

  Future<void> pairTrade({
    required Trade firstTrade,
    required String userId,
  }) =>
      firebaseMethods.pairTrade(
        firstTrade: firstTrade,
        userId: userId,
      );

  Future<String> getUserNameFromUserId({
    required String userId,
  }) =>
      firebaseMethods.getUserNameFromUserId(userId: userId);

  Future<Users?> verifyMobileNumberOrEmail({
    required String value,
  }) =>
      firebaseMethods.verifyMobileNumberOrEmail(value: value);

  Future<void> transferCoins({
    required String senderId,
    required String receiverId,
    required int deductCoins,
    required int transferCoins,
  }) =>
      firebaseMethods.transferCoins(
        senderId: senderId,
        receiverId: receiverId,
        deductCoins: deductCoins,
        transferCoins: transferCoins,
      );

  Future<List<Map<String, dynamic>>> getUserTradeActivities({
    required String userId,
    DateTime? lastTradeDate,
    String? lastTradeId,
    int? pageSize = 20,
  }) =>
      firebaseMethods.getUserTradeActivities(
        userId: userId,
        lastTradeDate: lastTradeDate,
        lastTradeId: lastTradeId,
        pageSize: pageSize,
      );

  Future<List<model.Transaction>> getUserPurchaseActivities({
    required String userId,
    DateTime? lastPurchaseDate,
    String? lastPurchaseId,
    int? pageSize,
  }) =>
      firebaseMethods.getUserPurchaseActivities(
        userId: userId,
        lastPurchaseDate: lastPurchaseDate,
        lastPurchaseId: lastPurchaseId,
        pageSize: pageSize,
      );

  Future<List<Payout>> getUserPayoutActivities({
    required String userId,
    DateTime? lastPayoutDate,
    String? lastPayoutId,
    int? pageSize,
  }) =>
      firebaseMethods.getUserPayoutActivities(
        userId: userId,
        lastPayoutDate: lastPayoutDate,
        lastPayoutId: lastPayoutId,
        pageSize: pageSize,
      );

  Future<List<Map<String, dynamic>>> getUserTransferActivities({
    required String userId,
    DateTime? lastTradeDate,
    String? lastTradeId,
    int? pageSize = 20,
  }) =>
      firebaseMethods.getUserTransferActivities(
        userId: userId,
        lastTradeDate: lastTradeDate,
        lastTradeId: lastTradeId,
        pageSize: pageSize,
      );

  Future<void> sendFeedback({
    required String category,
    required String subject,
    required String description,
    required Users user,
    File? image,
  }) =>
      firebaseMethods.sendFeedback(
        category: category,
        subject: subject,
        description: description,
        user: user,
        image: image,
      );

  Future<List<Trade>> getOpenTradesForUser({
    required String userId,
  }) =>
      firebaseMethods.getOpenTradesForUser(userId: userId);

  Future<String> getSubcategoryNameForQuestion({
    required String questionId,
  }) =>
      firebaseMethods.getSubcategoryNameForQuestion(questionId: questionId);

  Future<List<Trade>> getClosedTradesForUser({
    required String userId,
  }) =>
      firebaseMethods.getClosedTradesForUser(userId: userId);

  Future<void> updateTransactionDetails({
    required bool transactionStatus,
    String? transactionId,
    required String userId,
    required double amount,
    required int coins,
  }) =>
      firebaseMethods.updateTransactionDetails(
        transactionStatus: transactionStatus,
        transactionId: transactionId,
        userId: userId,
        amount: amount,
        coins: coins,
      );

  Future<bool> getPanVerificationStatus({
    required String userId,
  }) =>
      firebaseMethods.getPanVerificationStatus(
        userId: userId,
      );

  Future<bool> getQuestionActiveStatus({
    required String questionId,
  }) =>
      firebaseMethods.getQuestionActiveStatus(questionId: questionId);

  Future<String> getUserReferralCode({
    required String userId,
  }) =>
      firebaseMethods.getUserReferralCode(userId: userId);

  Future<bool> isPasswordSet({
    required String mobile,
  }) =>
      firebaseMethods.isPasswordSet(mobile: mobile);

  Future<void> setPassword({
    required String userId,
    required String password,
  }) =>
      firebaseMethods.setPassword(userId: userId, password: password);

  Future<void> submitPayoutRequest({
    String? accountNumber,
    String? ifscCode,
    String? upi,
    required double requestedAmount,
    required double finalAmount,
    required double commission,
    required int coins,
    required String userId,
    required String name,
  }) =>
      firebaseMethods.submitPayoutRequest(
        upi: upi,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        commission: commission,
        finalAmount: finalAmount,
        requestedAmount: requestedAmount,
        coins: coins,
        userId: userId,
        name: name,
      );

  Future<void> updatePanVerificationStatus({
    required String userId,
    required String pan,
  }) =>
      firebaseMethods.updatePanVerificationStatus(
        userId: userId,
        pan: pan,
      );
}
