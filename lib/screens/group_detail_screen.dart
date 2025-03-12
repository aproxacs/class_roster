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
                'notification'.tr,
                'csv_downloaded'.tr,
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
                                title: Text('edit_student'.tr),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'student_name'.tr,
                                        hintText: 'enter_student_name'.tr,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: studentIdController,
                                      decoration: InputDecoration(
                                        labelText: 'student_id'.tr,
                                        hintText: 'enter_student_id'.tr,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('cancel'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (nameController.text.isEmpty) {
                                        Get.snackbar(
                                          'error'.tr,
                                          'enter_student_name_error'.tr,
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
                                    child: Text('save'.tr),
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
                                title: Text('delete_student'.tr),
                                content: Text('delete_student_confirm'.trParams({'name': student.name})),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('cancel'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      studentController.deleteStudent(student.id!);
                                      Get.back();
                                    },
                                    child: Text('delete'.tr),
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
                          title: Text('add_student'.tr),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'student_name'.tr,
                                ),
                              ),
                              TextField(
                                controller: idController,
                                decoration: InputDecoration(
                                  labelText: 'student_id_optional'.tr,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('cancel'.tr),
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
                              child: Text('add'.tr),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('add_student'.tr),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (studentController.students.isEmpty) {
                        Get.snackbar(
                          'notification'.tr,
                          'no_students'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final titleController = TextEditingController(
                        text: '${group.name} ${DateTime.now().toString().split(' ')[0]}',
                      );
                      Get.dialog(
                        AlertDialog(
                          title: Text('new_attendance'.tr),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'attendance_title'.tr,
                                  hintText: 'attendance_title_hint'.tr,
                                ),
                                autofocus: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                if (titleController.text.isNotEmpty) {
                                  rosterController.createRoster(
                                    titleController.text,
                                    studentController.students,
                                  );
                                  Get.back();
                                  Get.off(() => const AttendanceHistoryScreen());
                                }
                              },
                              child: Text('create'.tr),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('new_attendance'.tr),
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