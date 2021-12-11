class Question {
  late String id;
  late String name;
  late String? image;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
  late bool isDeleted;
  late String parent;
  late List<String>? yesTrades;
  late List<String>? noTrades;
  late int? pairedTradesCount;
  late int? openTradesCount;
  late int? lastTradedPrice;
  late int? maxTradedPrice;
  late double? averageTradedPrice;
  late DateTime? closedAt;
  late bool? answer;

  Question({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isDeleted,
    required this.parent,
    this.image,
    this.yesTrades,
    this.noTrades,
    this.pairedTradesCount,
    this.openTradesCount,
    this.lastTradedPrice,
    this.maxTradedPrice,
    this.averageTradedPrice,
    this.closedAt,
    this.answer,
  });

  Map toMap(Question question) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = question.id;
    data['name'] = question.name;
    data['image'] = question.image;
    data['isActive'] = question.isActive;
    data['isDeleted'] = question.isDeleted;
    data['createdAt'] = question.createdAt;
    data['updatedAt'] = question.updatedAt;
    data['parent'] = question.parent;
    data['yesTrades'] = question.yesTrades;
    data['noTrades'] = question.noTrades;
    data['pairedTradesCount'] = question.pairedTradesCount;
    data['openTradesCount'] = question.openTradesCount;
    data['lastTradedPrice'] = question.lastTradedPrice;
    data['averageTradedPrice'] = question.averageTradedPrice;
    data['maxTradedPrice'] = question.maxTradedPrice;
    data['closedAt'] = question.closedAt;
    data['answer'] = question.answer;
    return data;
  }

  Question.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    name = mapData['name'];
    image = mapData['image'];
    isActive = mapData['isActive'];
    isDeleted = mapData['isDeleted'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    yesTrades = mapData['yesTrades'] != null
        ? List<String>.from(mapData['yesTrades'])
        : [];
    noTrades = mapData['noTrades'] != null
        ? List<String>.from(mapData['noTrades'])
        : [];
    parent = mapData['parent'];
    pairedTradesCount = mapData['pairedTradesCount'] ?? 0;
    openTradesCount = mapData['openTradesCount'] ?? 0;
    lastTradedPrice = mapData['lastTradedPrice'] ?? 0;
    averageTradedPrice = mapData['averageTradedPrice'] + .0 ?? 0;
    maxTradedPrice = mapData['maxTradedPrice'] ?? 0;
    if (mapData['closedAt'] != null) {
      closedAt = mapData['closedAt'].toDate();
    } else {
      closedAt = null;
    }
    answer = mapData['answer'];
  }
}
