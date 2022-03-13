class Wallet {
  late String id;
  late int bonusCoins;
  late int redeemableCoins;
  late bool isActive;
  late String userId;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;

  Wallet({
    required this.id,
    required this.bonusCoins,
    required this.redeemableCoins,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isDeleted = false,
  });

  Map toMap(Wallet wallet) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = wallet.id;
    data['bonusCoins'] = wallet.bonusCoins;
    data['redeemableCoins'] = wallet.redeemableCoins;
    data['isActive'] = wallet.isActive;
    data['userId'] = wallet.userId;
    data['createdAt'] = wallet.createdAt;
    data['updatedAt'] = wallet.updatedAt;
    data['isDeleted'] = wallet.isDeleted;
    return data;
  }

  Wallet.fromMap(Map<String, dynamic> mapData) {
    id = mapData['id'];
    bonusCoins = mapData['bonusConins'];
    redeemableCoins = mapData['redeemableCoins'];
    userId = mapData['userId'];
    isActive = mapData['isActive'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    isDeleted = mapData['isDeleted'];
  }
}
