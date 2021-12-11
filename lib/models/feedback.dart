class Feedback {
  late String id;
  late String category;
  late String subject;
  late String description;
  late String userId;
  late String? image;
  late DateTime createdAt;

  Feedback({
    required this.id,
    required this.category,
    required this.subject,
    required this.description,
    required this.userId,
    required this.createdAt,
    this.image,
  });

  Map toMap(Feedback feedback) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = feedback.id;
    data['category'] = feedback.category;
    data['subject'] = feedback.subject;
    data['description'] = feedback.description;
    data['createdAt'] = feedback.createdAt;
    data['image'] = feedback.image;
    data['userId'] = feedback.userId;
    return data;
  }

  Feedback.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    subject = mapData['subject'];
    category = mapData['category'];
    description = mapData['description'];
    image = mapData['image'];
    userId = mapData['userId'];
    createdAt = mapData['createdAt'].toDate();
  }
}
