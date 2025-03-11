import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_group.dart';
import '../controllers/student_controller.dart';
import '../controllers/roster_controller.dart';
import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import '../services/csv_service.dart';

class GroupDetailScreen extends StatelessWidget {
  final StudentGroup group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final studentController = Get.put(StudentController());
    final rosterController = Get.put(RosterController());

    // 학생 목록 로드
    studentController.loadStudents(group.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              await CsvService.instance.exportGroupToCSV(
                studentController.students,
                group.name,
              );
              Get.snackbar(
                '알림',
                'CSV 파일이 다운로드되었습니다.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () async {
              await studentController.importStudentsFromCsv(group.id!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: studentController.students.length,
                itemBuilder: (context, index) {
                  final student = studentController.students[index];
                  return ListTile(
                    title: Text(student.name),
                    subtitle: student.studentId != null
                        ? Text(student.studentId!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            final nameController = TextEditingController(text: student.name);
                            final studentIdController = TextEditingController(text: student.studentId);
                            
                            Get.dialog(
                              AlertDialog(
                                title: const Text('학생 정보 수정'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: '이름',
                                        hintText: '학생 이름을 입력하세요',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: studentIdController,
                                      decoration: const InputDecoration(
                                        labelText: '학번',
                                        hintText: '학번을 입력하세요',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (nameController.text.isEmpty) {
                                        Get.snackbar(
                                          '오류',
                                          '이름을 입력해주세요.',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }
                                      
                                      final updatedStudent = student.copyWith(
                                        name: nameController.text,
                                        studentId: studentIdController.text.isEmpty
                                            ? null
                                            : studentIdController.text,
                                      );
                                      
                                      studentController.updateStudent(updatedStudent);
                                      Get.back();
                                    },
                                    child: const Text('저장'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('학생 삭제'),
                                content: Text('${student.name}을(를) 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      studentController.deleteStudent(student.id!);
                                      Get.back();
                                    },
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final nameController = TextEditingController();
                      final idController = TextEditingController();
                      
                      Get.dialog(
                        AlertDialog(
                          title: const Text('새 학생 추가'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: '이름',
                                ),
                              ),
                              TextField(
                                controller: idController,
                                decoration: const InputDecoration(
                                  labelText: '학번 (선택사항)',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (nameController.text.isNotEmpty) {
                                  studentController.addStudent(
                                    nameController.text,
                                    group.id!,
                                    studentId: idController.text.isEmpty
                                        ? null
                                        : idController.text,
                                  );
                                  Get.back();
                                }
                              },
                              child: const Text('추가'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('학생 추가'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (studentController.students.isEmpty) {
                        Get.snackbar(
                          '알림',
                          '학생이 없습니다. 먼저 학생을 추가해주세요.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final titleController = TextEditingController(
                        text: '${group.name} ${DateTime.now().toString().split(' ')[0]}',
                      );
                      Get.dialog(
                        AlertDialog(
                          title: const Text('새 출석부'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: '출석부 제목',
                                  hintText: '예) 3월 첫째주 출석',
                                ),
                                autofocus: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (titleController.text.isNotEmpty) {
                                  await rosterController.createRoster(
                                    titleController.text,
                                    studentController.students,
                                  );
                                  Get.back();
                                  Get.to(() => const AttendanceHistoryScreen());
                                } else {
                                  Get.snackbar(
                                    '알림',
                                    '출석부 제목을 입력해주세요.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              child: const Text('생성'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('출석부 생성'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 