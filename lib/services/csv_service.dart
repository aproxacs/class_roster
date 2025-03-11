import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../models/roster.dart';
import '../models/student.dart';

class CsvService {
  CsvService._();
  static final CsvService instance = CsvService._();

  Future<void> exportRosterToCSV(
    List<RosterStudent> students,
    String title,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$title.csv');

    final List<List<dynamic>> rows = [];
    rows.add(['이름', '학번', '출석 상태']);

    for (final student in students) {
      rows.add([
        student.name,
        student.studentId ?? '',
        _getStatusText(student.status),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: title);
  }

  Future<void> exportGroupToCSV(
    List<Student> students,
    String groupName,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${groupName}_학생명단.csv');

    final List<List<dynamic>> rows = [];
    rows.add(['이름', '학번']);

    for (final student in students) {
      rows.add([
        student.name,
        student.studentId ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: '${groupName}_학생명단');
  }

  Future<List<List<dynamic>>> importStudentsFromCSV(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString();
    return const CsvToListConverter().convert(contents);
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return '출석';
      case AttendanceStatus.absent:
        return '결석';
      case AttendanceStatus.late:
        return '지각';
      case AttendanceStatus.excused:
        return '사유';
    }
  }
} 