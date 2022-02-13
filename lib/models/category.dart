class Category {
  late String id;
  late String name;
  late String? image;
  late String createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isActive;
  late bool isDeleted;
  late String? parent;
  late List<String>? children;
  late int openEvents;
  late int closedEvents;
  late int priority;

  Category({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.priority,

    this.image,
    this.isActive = true,
    this.isDeleted = false,
    this.parent,
    this.children,
    this.openEvents = 0,
    this.closedEvents = 0,
  });

  Map toMap(Category category) {
    var data = <String, dynamic>{};
    data['id'] = category.id;
    data['name'] = category.name;
    data['image'] = category.image;
    data['createdBy'] = category.createdBy;
    data['createdAt'] = category.createdAt;
    data['updatedAt'] = category.updatedAt;
    data['isActive'] = category.isActive;
    data['isDeleted'] = category.isDeleted;
    data['parent'] = category.parent;
    data['children'] = category.children;
    data['openEvents'] = category.openEvents;
    data['closedEvents'] = category.closedEvents;
    data['priority'] = category.priority;
    return data;
  }

  Category.fromMap(Map<dynamic, dynamic> mapData) {
    id = mapData['id'];
    name = mapData['name'];
    priority = mapData['priority'];
    image = mapData['image'] ?? '';
    createdBy = mapData['createdBy'] ?? "";
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
