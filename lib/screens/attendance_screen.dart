import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/roster.dart';
import '../controllers/roster_controller.dart';
import '../models/roster.dart' as roster_model;

class AttendanceScreen extends StatelessWidget {
  final Roster roster;

  const AttendanceScreen({
    super.key,
    required this.roster,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      Get.snackbar(
        '오류',
        '전화를 걸 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RosterController());
    controller.loadRosterStudents(roster.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(roster.title),
        centerTitle: true,
        actions: [
          Obx(() {
            final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
            if (currentRoster.status == roster_model.RosterStatus.open) {
              return IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text('close_attendance'.tr),
                      content: Text('close_attendance_confirm'.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('cancel'.tr),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.closeRoster(roster);
                            Get.back();
                          },
                          child: Text('close'.tr),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
            if (currentRoster.status == roster_model.RosterStatus.closed) {
              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  controller.exportRosterToCSV(
                    '${roster.title}_${roster.date.toString().split(' ')[0]}',
                  );
                  Get.snackbar(
                    'notification'.tr,
                    'csv_downloaded'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final students = controller.rosterStudents;
        if (students.isEmpty) {
          return Center(
            child: Text('no_students'.tr),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return GestureDetector(
              onLongPress: () {
                if (student.status == roster_model.AttendanceStatus.absent &&
                    student.phoneNumber != null &&
                    student.phoneNumber!.isNotEmpty) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('전화 걸기'),
                      content: Text('${student.name}(${student.phoneNumber})에게 전화를 걸까요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            _makePhoneCall(student.phoneNumber!);
                          },
                          child: const Text('전화 걸기'),
                        ),
                      ],
                    ),
                  );
                }
              },
              onTap: roster.status == roster_model.RosterStatus.open
                  ? () {
                      final newStatus = student.status == roster_model.AttendanceStatus.absent
                          ? roster_model.AttendanceStatus.present
                          : roster_model.AttendanceStatus.absent;
                      controller.updateStudentStatus(student, newStatus);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(student.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (student.studentId != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            student.studentId!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.phone,
                              size: 12,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(student.status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getStatusText(roster_model.AttendanceStatus status) {
    switch (status) {
      case roster_model.AttendanceStatus.present:
        return 'present'.tr;
      case roster_model.AttendanceStatus.absent:
        return 'absent'.tr;
      case roster_model.AttendanceStatus.late:
        return 'late'.tr;
      case roster_model.AttendanceStatus.excused:
        return 'excused'.tr;
    }
  }

  Color _getStatusColor(roster_model.AttendanceStatus status) {
    switch (status) {
      case roster_model.AttendanceStatus.present:
        return Colors.green;
      case roster_model.AttendanceStatus.absent:
        return Colors.red;
      case roster_model.AttendanceStatus.late:
        return Colors.orange;
      case roster_model.AttendanceStatus.excused:
        return Colors.blue;
    }
  }
} 