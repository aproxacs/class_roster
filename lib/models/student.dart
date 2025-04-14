class Student {
  final int? id;
  final String name;
  final String? studentId;
  final String? phoneNumber;
  final int groupId;
  final DateTime createdAt;

  Student({
    this.id,
    required this.name,
    this.studentId,
    this.phoneNumber,
    required this.groupId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Student copyWith({
    int? id,
    String? name,
    String? studentId,
    String? phoneNumber,
    int? groupId,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId,
      phoneNumber: phoneNumber,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'phone_number': phoneNumber,
      'group_id': groupId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int,
      name: map['name'] as String,
      studentId: map['student_id'] as String?,
      phoneNumber: map['phone_number'] as String?,
      groupId: map['group_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
} 