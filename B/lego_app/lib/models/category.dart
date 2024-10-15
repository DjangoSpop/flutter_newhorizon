class Category {
  final int id;
  final String name;
  final int? parentId;

  Category({required this.id, required this.name, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parentId: json['parent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent': parentId,
    };
  }
}