enum PayoutStatus {
  // ignore: constant_identifier_names
  PENDING,
  // ignore: constant_identifier_names
  PROCESSING,
  // ignore: constant_identifier_names
  SUCCEEDED,
  // ignore: constant_identifier_names
  FAILED,
}

class Payout {
  late String? accountNumber;
  late String accountHolderName;
  late DateTime createdAt;
  late int coins;
  late double commission;
  late double finalAmount;
  late String id;
  late String? ifscCode;
  late double requestedAmount;
  late PayoutStatus status;
  late DateTime updatedAt;
  late String? upi;
  late String userId;

  Payout({
    this.accountNumber,
    required this.accountHolderName,
    required this.createdAt,
    required this.coins,
    required this.commission,
    required this.finalAmount,
    required this.id,
    this.ifscCode,
    required this.requestedAmount,
    required this.status,
    required this.updatedAt,
    this.upi,
    required this.userId,
  });

  Map toMap(Payout request) {
    var data = <String, dynamic>{};
    data["accountNumber"] = request.accountNumber;
    data["accountHolderName"] = request.accountHolderName;
    data["createdAt"] = request.createdAt;
    data["coins"] = request.coins;
    data["commission"] = request.commission;
    data["finalAmount"] = request.finalAmount;
    data["id"] = request.id;
    data["ifscCode"] = request.ifscCode;
    data["requestedAmount"] = request.requestedAmount;
    data["status"] = request.status.toString().split('.').last;
    data["updatedAt"] = request.updatedAt;
    data["upi"] = request.upi;
    data["userId"] = request.userId;
    return data;
  }

  Payout.fromMap(Map<String, dynamic> mapData) {
    accountNumber = mapData["accountNumber"];
    accountHolderName = mapData["accountHolderName"];
    createdAt = mapData["createdAt"].toDate();
    coins = mapData["coins"];
    commission = mapData["commission"].toDouble();
    finalAmount = mapData["finalAmount"].toDouble();
    id = mapData["id"];
    ifscCode = mapData["ifscCode"];
    requestedAmount = mapData["requestedAmount"].toDouble();
    status = PayoutStatus.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['status']);

    updatedAt = mapData["updatedAt"].toDate();
    upi = mapData["upi"];
    userId = mapData["userId"];
  }
}
