enum RosterStatus {
  open,
  closed,
}

enum AttendanceStatus {
  present,
  late,
  absent,
  excused,
}

class Roster {
  final int? id;
  final String title;
  final DateTime date;
  final RosterStatus status;
  final String groupName;

  Roster({
    this.id,
    required this.title,
    required this.date,
    this.status = RosterStatus.open,
    required this.groupName,
  });

  Roster copyWith({
    int? id,
    String? title,
    DateTime? date,
    RosterStatus? status,
    String? groupName,
  }) {
    return Roster(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      status: status ?? this.status,
      groupName: groupName ?? this.groupName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'group_name': groupName,
    };
  }

  factory Roster.fromMap(Map<String, dynamic> map) {
    return Roster(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      status: RosterStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RosterStatus.open,
      ),
      groupName: map['group_name'],
    );
  }
}

class RosterStudent {
  final int? id;
  final int rosterId;
  final String name;
  final String? studentId;
  final AttendanceStatus status;

  RosterStudent({
    this.id,
    required this.rosterId,
    required this.name,
    this.studentId,
    this.status = AttendanceStatus.absent,
  });

  RosterStudent copyWith({
    int? id,
    int? rosterId,
    String? name,
    String? studentId,
    AttendanceStatus? status,
  }) {
    return RosterStudent(
      id: id ?? this.id,
      rosterId: rosterId ?? this.rosterId,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roster_id': rosterId,
      'name': name,
      'student_id': studentId,
      'status': status.toString().split('.').last,
    };
  }

  factory RosterStudent.fromMap(Map<String, dynamic> map) {
    return RosterStudent(
      id: map['id'],
      rosterId: map['roster_id'],
      name: map['name'],
      studentId: map['student_id'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
    );
  }
} 