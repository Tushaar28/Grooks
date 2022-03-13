class Users {
  late String id;
  late String name;
  late String? email;
  late String? mobile;
  late String? city;
  late DateTime? dateOfBirth;
  late String referralCode;
  late String? image;
  late bool isActive;
  late DateTime? lastLoginAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  late String? referredBy;
  late bool isPanVerified;
  late String? accountNumber;
  late String? ifscCode;
  late String? panNumber;
  late String? password;

  Users({
    required this.id,
    required this.name,
    required this.referralCode,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.isPanVerified = false,
    this.mobile,
    this.email,
    this.city,
    this.dateOfBirth,
    this.image,
    this.isActive = true,
    this.isDeleted = false,
    this.referredBy,
    this.accountNumber,
    this.ifscCode,
    this.panNumber,
    this.password,
  });

  Map toMap(Users user) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = user.id;
    data['name'] = user.name;
    data['email'] = user.email;
    data['mobile'] = user.mobile;
    data['city'] = user.city;
    data['dateOfBirth'] = user.dateOfBirth;
    data['referralCode'] = user.referralCode;
    data['image'] = user.image;
    data['isActive'] = user.isActive;
    data['lastLoginAt'] = user.lastLoginAt;
    data['createdAt'] = user.createdAt;
    data['updatedAt'] = user.updatedAt;
    data['isDeleted'] = user.isDeleted;
    data['referredBy'] = user.referredBy;
    data['accountNumber'] = user.accountNumber;
    data['ifscCode'] = user.ifscCode;
    data['panNumber'] = user.panNumber;
    data['isPanVerified'] = user.isPanVerified;
    data['password'] = user.password;
    return data;
  }

  Users.fromMap(Map<String, dynamic> mapData) {
    id = mapData['id'];
    name = mapData['name'];
    email = mapData['email'];
    mobile = mapData['mobile'];
    city = mapData['city'];
    if (mapData['dateOfBirth'] != null) {
      dateOfBirth = mapData['dateOfBirth'].toDate();
    } else {
      dateOfBirth = null;
    }
    referralCode = mapData['referralCode'];
    image = mapData['image'];
    isActive = mapData['isActive'] ?? true;
    if (mapData['lastLoginAt'] != null) {
      lastLoginAt = mapData['lastLoginAt'].toDate();
    } else {
      lastLoginAt = null;
    }
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    isDeleted = mapData['isDeleted'];
    referredBy = mapData['referredBy'];
    accountNumber = mapData['accountNumber'];
    ifscCode = mapData['ifscCode'];
    panNumber = mapData['panNumber'];
    isPanVerified = mapData['isPanVerified'];
    password = mapData['password'];
  }
}
