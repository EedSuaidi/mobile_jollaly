class Note {
  final String id;
  String title;
  String content;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isFavorite;
  bool isArchived;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.isArchived = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      isFavorite: (json['isFavorite'] ?? false) as bool,
      isArchived: (json['isArchived'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'userId': userId,
    'isFavorite': isFavorite,
    'isArchived': isArchived,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}
