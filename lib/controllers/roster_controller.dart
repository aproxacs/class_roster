import 'package:get/get.dart';
import '../models/roster.dart';
import '../models/student.dart';
import '../services/database_service.dart';
import '../services/csv_service.dart';

class RosterController extends GetxController {
  final _rosters = <Roster>[].obs;
  final _selectedRoster = Rxn<Roster>();
  final _rosterStudents = <RosterStudent>[].obs;

  List<Roster> get rosters => _rosters;
  Roster? get selectedRoster => _selectedRoster.value;
  List<RosterStudent> get rosterStudents => _rosterStudents;

  Future<void> loadRosters() async {
    final sheets = await DatabaseService.instance.getAllRosters();
    _rosters.assignAll(sheets);
  }

  Future<void> createRoster(String title, List<Student> students) async {
    final roster = Roster(
      title: title,
      date: DateTime.now(),
    );
    final savedRoster = await DatabaseService.instance.createRoster(roster);
    _rosters.add(savedRoster);

    // 학생 정보 복사
    for (final student in students) {
      final rosterStudent = RosterStudent(
        rosterId: savedRoster.id!,
        name: student.name,
        studentId: student.studentId,
      );
      final savedStudent = await DatabaseService.instance.createRosterStudent(rosterStudent);
      _rosterStudents.add(savedStudent);
    }
  }

  Future<void> deleteRoster(int id) async {
    await DatabaseService.instance.deleteRoster(id);
    _rosters.removeWhere((roster) => roster.id == id);
    if (_selectedRoster.value?.id == id) {
      _selectedRoster.value = null;
      _rosterStudents.clear();
    }
  }

  Future<void> closeRoster(Roster roster) async {
    final updatedRoster = roster.copyWith(
      status: RosterStatus.closed,
    );
    await DatabaseService.instance.updateRoster(updatedRoster);
    final index = _rosters.indexWhere((r) => r.id == roster.id);
    if (index != -1) {
      _rosters[index] = updatedRoster;
      _rosters.refresh();
    }
  }

  Future<void> loadRosterStudents(int rosterId) async {
    final students = await DatabaseService.instance.getRosterStudents(rosterId);
    _rosterStudents.assignAll(students);
  }

  Future<void> updateStudentStatus(RosterStudent student, AttendanceStatus status) async {
    final updatedStudent = student.copyWith(status: status);
    await DatabaseService.instance.updateRosterStudent(updatedStudent);
    final index = _rosterStudents.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _rosterStudents[index] = updatedStudent;
      _rosterStudents.refresh();
    }
  }

  Future<void> exportRosterToCSV(String title) async {
    await CsvService.instance.exportRosterToCSV(
      _rosterStudents,
      title,
    );
  }

  void selectRoster(Roster roster) {
    _selectedRoster.value = roster;
    loadRosterStudents(roster.id!);
  }
} 