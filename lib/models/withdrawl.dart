enum WithdrawlStatus {
  // ignore: constant_identifier_names
  PROCESSING,
  // ignore: constant_identifier_names
  PROCESSED,
  // ignore: constant_identifier_names
  FAILED,
}

class Withdrawl {
  late String id;
  late String userId;
  late DateTime createdAt;
  late DateTime updatedAt;
  late double amount;
  late String? upi;
  late String? accountNumber;
  late String? ifscCode;
  late String? transactionId;
  late WithdrawlStatus status;

  Withdrawl({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
    required this.status,
    this.upi,
    this.accountNumber,
    this.ifscCode,
    this.transactionId,
  });

  Map toMap(Withdrawl withdrawl) {
    var data = <String, dynamic>{};
    data['id'] = withdrawl.id;
    data['userId'] = withdrawl.userId;
    data['createdAt'] = withdrawl.createdAt;
    data['updatedAt'] = withdrawl.updatedAt;
    data['amount'] = withdrawl.amount;
    data['upi'] = withdrawl.upi;
    data['accountNumber'] = withdrawl.accountNumber;
    data['ifscCode'] = withdrawl.ifscCode;
    data['transactionId'] = withdrawl.transactionId;
    data['status'] = withdrawl.status.toString().split('.').last;
    return data;
  }

  Withdrawl.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    userId = mapData['userId'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    amount = mapData['amount'];
    upi = mapData['upi'];
    accountNumber = mapData['accountNumber'];
    ifscCode = mapData['ifscCode'];
    transactionId = mapData['transactionId'];
    status = WithdrawlStatus.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['status']);
  }
}
