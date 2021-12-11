class Category {
  late String id;
  late String name;
  late String? image;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
  late bool isDeleted;
  late String? parent;
  late List<String>? children;
  late int openEvents;
  late int closedEvents;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isDeleted,
    this.openEvents = 0,
    this.closedEvents = 0,
    this.image,
    this.parent,
    this.children,
  });

  Map toMap(Category category) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = category.id;
    data['name'] = category.name;
    data['image'] = category.image;
    data['createdAt'] = category.createdAt;
    data['updatedAt'] = category.updatedAt;
    data['isActive'] = category.isActive;
    data['isDeleted'] = category.isDeleted;
    data['parent'] = category.parent;
    data['children'] = category.children;
    data['openEvents'] = category.openEvents;
    data['closedEvents'] = category.closedEvents;
    return data;
  }

  Category.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    name = mapData['name'];
    image = mapData['image'];
    createdAt = mapData['createdAt'].toDate();
    updatedAt = mapData['updatedAt'].toDate();
    isActive = mapData['isActive'] ?? true;
    isDeleted = mapData['isDeleted'] ?? false;
    parent = mapData['parent'] ?? '';
    children = mapData['children'] != null
        ? List<String>.from(mapData['children'])
        : [];
    openEvents = mapData['openEvents'] ?? 0;
    closedEvents = mapData['closedEvents'] ?? 0;
  }
}
