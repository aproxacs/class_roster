import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student_group.dart';
import '../models/student.dart';
import '../models/roster.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('class_roster.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE student_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        student_id TEXT,
        phone_number TEXT,
        group_id INTEGER NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (group_id) REFERENCES student_groups (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE rosters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        group_name TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE roster_students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roster_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        student_id TEXT,
        phone_number TEXT,
        status TEXT NOT NULL DEFAULT 'absent',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (roster_id) REFERENCES rosters (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // 버전 1에서 2으로 업그레이드
      if (oldVersion < 2) {
        // students 테이블에 phone_number 컬럼이 없으면 추가
        try {
          await db.execute('ALTER TABLE students ADD COLUMN phone_number TEXT');
        } catch (e) {
          // 이미 컬럼이 존재하는 경우 무시
        }
        
        // roster_students 테이블에 phone_number 컬럼이 없으면 추가
        try {
          await db.execute('ALTER TABLE roster_students ADD COLUMN phone_number TEXT');
        } catch (e) {
          // 이미 컬럼이 존재하는 경우 무시
        }
      }
    } catch (e) {
      // 업그레이드 중 오류가 발생하면 로그를 남기고 계속 진행
      print('Database upgrade error: $e');
    }
  }

  // StudentGroup CRUD operations
  Future<StudentGroup> createStudentGroup(StudentGroup group) async {
    final db = await database;
    final id = await db.insert('student_groups', group.toMap());
    return group.copyWith(id: id);
  }

  Future<List<StudentGroup>> getAllStudentGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('student_groups');
    return List.generate(maps.length, (i) => StudentGroup.fromMap(maps[i]));
  }

  Future<StudentGroup?> getStudentGroup(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'student_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StudentGroup.fromMap(maps.first);
  }

  Future<int> updateStudentGroup(StudentGroup group) async {
    final db = await database;
    return db.update(
      'student_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteStudentGroup(int id) async {
    final db = await database;
    return await db.delete(
      'student_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Student CRUD operations
  Future<Student> createStudent(Student student) async {
    final db = await database;
    final id = await db.insert('students', student.toMap());
    return student.copyWith(id: id);
  }

  Future<List<Student>> getStudentsByGroup(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Roster CRUD operations
  Future<Roster> createRoster(Roster roster) async {
    final db = await database;
    final id = await db.insert('rosters', roster.toMap());
    return roster.copyWith(id: id);
  }

  Future<List<Roster>> getAllRosters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rosters',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Roster.fromMap(maps[i]));
  }

  Future<int> updateRoster(Roster roster) async {
    final db = await database;
    return db.update(
      'rosters',
      roster.toMap(),
      where: 'id = ?',
      whereArgs: [roster.id],
    );
  }

  Future<int> deleteRoster(int id) async {
    final db = await database;
    return await db.delete(
      'rosters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // RosterStudent operations
  Future<RosterStudent> createRosterStudent(RosterStudent student) async {
    final db = await database;
    final id = await db.insert('roster_students', student.toMap());
    return student.copyWith(id: id);
  }

  Future<List<RosterStudent>> getRosterStudents(int rosterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'roster_students',
      where: 'roster_id = ?',
      whereArgs: [rosterId],
    );
    return List.generate(maps.length, (i) => RosterStudent.fromMap(maps[i]));
  }

  Future<int> updateRosterStudent(RosterStudent student) async {
    final db = await database;
    return db.update(
      'roster_students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteRosterStudent(int id) async {
    final db = await database;
    return await db.delete(
      'roster_students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getStudentCountByGroup(int groupId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE group_id = ?',
      [groupId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
} 