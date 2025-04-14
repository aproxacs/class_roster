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
        title: Text('attendance'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final titleController = TextEditingController();
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('new_attendance'.tr),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => DropdownButton<int>(
                          isExpanded: true,
                          hint: Text('select_group'.tr),
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
                      onPressed: () async {
                        if (groupController.selectedGroup == null) {
                          Get.snackbar(
                            'notification'.tr,
                            'select_group_first'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        
                        if (titleController.text.isEmpty) {
                          Get.snackbar(
                            'notification'.tr,
                            'enter_title'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final students = await DatabaseService.instance
                            .getStudentsByGroup(groupController.selectedGroup!.id!);
                        
                        await rosterController.createRoster(
                          titleController.text,
                          students,
                          groupController.selectedGroup!.name,
                        );
                        Get.back();
                      },
                      child: Text('create'.tr),
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
            return Center(
              child: Text('no_attendance'.tr),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
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
                      title: Text('delete_attendance'.tr),
                      content: Text('delete_attendance_confirm'.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('cancel'.tr),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(
                            'delete'.tr,
                            style: const TextStyle(color: Colors.red),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(roster.groupName),
                            const SizedBox(width: 8),
                            Text('·'),
                            const SizedBox(width: 8),
                            Text(roster.date.toString().split(' ')[0]),
                          ],
                        ),
                      ],
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
                            ? 'in_progress'.tr
                            : 'completed'.tr,
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