enum TransactionType {
  // ignore: constant_identifier_names
  COINS_ADDED,
  // ignore: constant_identifier_names
  COINS_LOST,
  // ignore: constant_identifier_names
  COINS_SENT,
  // ignore: constant_identifier_names
  COINS_RECEIVED,
  // ignore: constant_identifier_names
  AMOUNT_ADDED,
  // ignore: constant_identifier_names
  AMOUNT_WITHDRAWN,
}

enum TransactionStatus {
  // ignore: constant_identifier_names
  PROCESSING,
  // ignore: constant_identifier_names
  PROCESSED,
  // ignore: constant_identifier_names
  FAILED,
}

class Transaction {
  late String id;
  late DateTime createdAt;
  late DateTime updatedAt;
  late TransactionStatus status;
  late TransactionType type;
  late double? amount;
  late int? redeemableCoins;
  late int? bonusCoins;
  late String? questionId;
  late String? receiverId;
  late String? senderId;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.status,
    required this.updatedAt,
    this.amount,
    this.redeemableCoins,
    this.bonusCoins,
    this.questionId,
    this.receiverId,
    this.senderId,
  });

  Map toMap(Transaction transaction) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = transaction.id;
    data['createdAt'] = transaction.createdAt;
    data['updatedAt'] = transaction.updatedAt;
    data['type'] = transaction.type.toString().split('.').last;
    data['status'] = transaction.status.toString().split('.').last;
    data['amount'] = transaction.amount;
    data['redeemableCoins'] = transaction.redeemableCoins;
    data['bonusCoins'] = transaction.bonusCoins;
    data['questionId'] = transaction.questionId;
    data['receiverId'] = transaction.receiverId;
    data['senderId'] = transaction.senderId;
    return data;
  }

  Transaction.fromMap(Map<String, dynamic> mapData) {
    id = mapData['id'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    type = TransactionType.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['type']);
    status = TransactionStatus.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['status']);
    amount = mapData['amount'];
    redeemableCoins = mapData['redeemableCoins'];
    bonusCoins = mapData['bonusCoins'];
    questionId = mapData['questionId'];
    receiverId = mapData['receiverId'];
    senderId = mapData['senderId'];
  }
}
