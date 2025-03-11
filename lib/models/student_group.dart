class StudentGroup {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;

  StudentGroup({
    this.id,
    required this.name,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StudentGroup copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return StudentGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StudentGroup.fromMap(Map<String, dynamic> map) {
    return StudentGroup(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
} 