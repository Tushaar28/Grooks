enum Status {
  // ignore: constant_identifier_names
  WON,
  // ignore: constant_identifier_names
  CANCELLED_BY_USER,
  // ignore: constant_identifier_names
  AUTO_CANCEL,
  // ignore: constant_identifier_names
  ACTIVE_UNPAIRED,
  // ignore: constant_identifier_names
  ACTIVE_PAIRED,
  // ignore: constant_identifier_names
  LOST,
}

class Trade {
  late String id;
  late String userId;
  late bool response;
  late int coins;
  late String questionId;
  late int redeemableCoinsUsed;
  late int bonusCoinsUsed;
  late DateTime createdAt;
  late DateTime updatedAt;
  late Status status;
  late DateTime? pairedAt;
  late DateTime? cancelledAt;
  late String? pairedTradeId;
  late int? coinsWon;

  Trade({
    required this.id,
    required this.userId,
    required this.response,
    required this.coins,
    required this.questionId,
    required this.redeemableCoinsUsed,
    required this.bonusCoinsUsed,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.pairedAt,
    this.cancelledAt,
    this.pairedTradeId,
    this.coinsWon,
  });

  Map toMap(Trade trade) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = trade.id;
    data['userId'] = trade.userId;
    data['response'] = trade.response;
    data['coins'] = trade.coins;
    data['questionId'] = trade.questionId;
    data['redeemableCoinsUsed'] = trade.redeemableCoinsUsed;
    data['bonusCoinsUsed'] = trade.bonusCoinsUsed;
    data['createdAt'] = trade.createdAt;
    data['updatedAt'] = trade.updatedAt;
    data['pairedAt'] = trade.pairedAt;
    data['cancelledAt'] = trade.cancelledAt;
    data['pairedTradeId'] = trade.pairedTradeId;
    data['status'] = trade.status.toString().split('.').last;
    data['coinsWon'] = trade.coinsWon;
    return data;
  }

  Trade.fromMap(Map<String, dynamic> mapData) {
    id = mapData['id'];
    userId = mapData['userId'];
    response = mapData['response'];
    coins = mapData['coins'];
    questionId = mapData['questionId'];
    redeemableCoinsUsed = mapData['redeemableCoinsUsed'];
    bonusCoinsUsed = mapData['bonusCoinsUsed'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    if (mapData['cancelledAt'] != null) {
      cancelledAt = mapData['cancelledAt'].toDate();
    } else {
      cancelledAt = null;
    }
    if (mapData['pairedAt'] != null) {
      pairedAt = mapData['pairedAt'].toDate();
    } else {
      pairedAt = null;
    }
    status = Status.values.firstWhere(
        (element) => element.toString().split('.').last == mapData['status']);
    pairedTradeId = mapData['pairedTradeId'];
    coinsWon = mapData['coinsWon'];
  }
}
