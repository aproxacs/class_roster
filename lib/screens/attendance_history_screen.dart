import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_group_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/roster_controller.dart';
import '../models/roster.dart';
import '../services/database_service.dart';
import 'attendance_screen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.put(StudentGroupController());
    final studentController = Get.put(StudentController());
    final rosterController = Get.put(RosterController());

    // 화면이 처음 로드될 때 출석부 목록을 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rosterController.loadRosters();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('출석부'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final titleController = TextEditingController();
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('새 출석부'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text('그룹 선택'),
                          value: groupController.selectedGroup?.id,
                          items: groupController.groups.map((group) {
                            return DropdownMenuItem(
                              value: group.id,
                              child: Text(group.name),
                            );
                          }).toList(),
                          onChanged: (groupId) {
                            if (groupId != null) {
                              final group = groupController.groups
                                  .firstWhere((g) => g.id == groupId);
                              groupController.selectGroup(group);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
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
                        if (groupController.selectedGroup == null) {
                          Get.snackbar(
                            '알림',
                            '그룹을 선택해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        
                        if (titleController.text.isEmpty) {
                          Get.snackbar(
                            '알림',
                            '출석부 제목을 입력해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final students = await DatabaseService.instance
                            .getStudentsByGroup(groupController.selectedGroup!.id!);
                        
                        await rosterController.createRoster(
                          titleController.text,
                          students,
                        );
                        Get.back();
                      },
                      child: const Text('생성'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () {
          final sheets = rosterController.rosters;
          if (sheets.isEmpty) {
            return const Center(
              child: Text('출석부가 없습니다.'),
            );
          }

          return ListView.builder(
            itemCount: sheets.length,
            itemBuilder: (context, index) {
              final roster = sheets[index];
              return Dismissible(
                key: Key(roster.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('출석부 삭제'),
                      content: const Text('이 출석부를 삭제하시겠습니까?\n삭제된 출석부는 복구할 수 없습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text(
                            '삭제',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (direction) {
                  rosterController.deleteRoster(roster.id!);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      roster.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      roster.date.toString().split(' ')[0],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: roster.status == RosterStatus.open
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        roster.status == RosterStatus.open
                            ? '진행 중'
                            : '종료됨',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    onTap: () {
                      rosterController.selectRoster(roster);
                      Get.to(() => AttendanceScreen(
                            roster: roster,
                            students: rosterController.rosterStudents,
                          ));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 