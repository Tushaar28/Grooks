class Transfer {
  late String id;
  late String senderId;
  late String receiverId;
  late int coins;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSuccess;

  Transfer({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.coins,
    required this.createdAt,
    required this.updatedAt,
    required this.isSuccess,
  });

  Map toMap(Transfer transfer) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = transfer.id;
    data['senderId'] = transfer.senderId;
    data['receiverId'] = transfer.receiverId;
    data['coins'] = transfer.coins;
    data['createdAt'] = transfer.createdAt;
    data['updatedAt'] = transfer.updatedAt;
    data['isSuccess'] = transfer.isSuccess;
    return data;
  }

  Transfer.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    senderId = mapData['senderId'];
    receiverId = mapData['receiverId'];
    coins = mapData['coins'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    isSuccess = mapData['isSuccess'];
  }
}
