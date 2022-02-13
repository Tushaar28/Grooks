// enum TransactionType {
//   // ignore: constant_identifier_names
//   COINS_ADDED,
//   // ignore: constant_identifier_names
//   COINS_LOST,
//   // ignore: constant_identifier_names
//   COINS_SENT,
//   // ignore: constant_identifier_names
//   COINS_RECEIVED,
//   // ignore: constant_identifier_names
//   AMOUNT_ADDED,
//   // ignore: constant_identifier_names
//   AMOUNT_WITHDRAWN,
// }

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
  // late TransactionType type;
  late String transactionId;
  late double amount;
  late int coins;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.updatedAt,
    required this.amount,
    required this.transactionId,
  });

  Map toMap(Transaction transaction) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = transaction.id;
    data['createdAt'] = transaction.createdAt;
    data['updatedAt'] = transaction.updatedAt;
    data['status'] = transaction.status.toString().split('.').last;
    data['amount'] = transaction.amount;
    data['transactionId'] = transaction.transactionId;
    return data;
  }

  Transaction.fromMap(Map<String, dynamic> mapData) {
    id = mapData['id'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    status = TransactionStatus.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['status']);
    amount = mapData['amount'];
    transactionId = mapData['transactionId'];
  }
}
