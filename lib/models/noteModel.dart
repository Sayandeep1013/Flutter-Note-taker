class NoteModel {
  int? id;
  String title;
  String description;
  String category;
  DateTime createdAt;
  bool isPinned;

  NoteModel({
    this.id,
    required this.title,
    required this.description,
    this.category = 'Uncategorized',
    required this.createdAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      isPinned: map['isPinned'] == 1,
    );
  }
}