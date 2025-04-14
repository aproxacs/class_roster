import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student.dart';
import '../services/database_service.dart';
import '../services/csv_service.dart';
import 'student_group_controller.dart';

class StudentController extends GetxController {
  final _students = <Student>[].obs;
  
  List<Student> get students => _students;

  Future<void> loadStudents(int groupId) async {
    final students = await DatabaseService.instance.getStudentsByGroup(groupId);
    _students.assignAll(students);
  }

  Future<void> addStudent(String name, int groupId, {String? studentId, String? phoneNumber}) async {
    final student = Student(
      name: name,
      studentId: studentId,
      phoneNumber: phoneNumber,
      groupId: groupId,
    );
    final savedStudent = await DatabaseService.instance.createStudent(student);
    _students.add(savedStudent);
    
    // 학생 수 업데이트
    final groupController = Get.find<StudentGroupController>();
    final count = await DatabaseService.instance.getStudentCountByGroup(groupId);
    groupController.updateStudentCount(groupId, count);
  }

  Future<void> updateStudent(Student student) async {
    // 학번이 빈 문자열이면 null로 설정
    final updatedStudent = student.copyWith(
      studentId: student.studentId?.trim().isEmpty ?? true ? null : student.studentId,
      phoneNumber: student.phoneNumber?.trim().isEmpty ?? true ? null : student.phoneNumber,
    );
    await DatabaseService.instance.updateStudent(updatedStudent);
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      _students.refresh();
    }
  }

  Future<void> deleteStudent(int id) async {
    final student = _students.firstWhere((s) => s.id == id);
    await DatabaseService.instance.deleteStudent(id);
    _students.removeWhere((student) => student.id == id);
    
    // 학생 수 업데이트
    final groupController = Get.find<StudentGroupController>();
    final count = await DatabaseService.instance.getStudentCountByGroup(student.groupId);
    groupController.updateStudentCount(student.groupId, count);
  }

  Future<void> importStudentsFromCsv(int groupId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        if (file.path != null) {
          final rows = await CsvService.instance.importStudentsFromCSV(file.path!);
          
          // 첫 번째 행은 헤더이므로 제외
          for (var i = 1; i < rows.length; i++) {
            final row = rows[i];
            if (row.length >= 2) {
              final name = row[0].toString();
              final studentId = row.length > 1 && row[1].toString().isNotEmpty ? row[1].toString() : null;
              final phoneNumber = row.length > 2 && row[2].toString().isNotEmpty ? row[2].toString() : null;
              
              await addStudent(
                name,
                groupId,
                studentId: studentId,
                phoneNumber: phoneNumber,
              );
            }
          }

          Get.snackbar(
            '알림',
            '학생 명단을 가져왔습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        'CSV 파일을 가져오는 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 