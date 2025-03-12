import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/roster.dart';
import '../controllers/roster_controller.dart';

class AttendanceScreen extends StatelessWidget {
  final Roster roster;
  final List<RosterStudent> students;

  const AttendanceScreen({
    super.key,
    required this.roster,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RosterController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(roster.title),
        centerTitle: true,
        actions: [
          Obx(() {
            final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentRoster.status == RosterStatus.open ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  currentRoster.status == RosterStatus.open
                      ? 'in_progress'.tr
                      : 'completed'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
            if (currentRoster.status == RosterStatus.open) {
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
            if (currentRoster.status == RosterStatus.closed) {
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
      body: Obx(
        () => GridView.builder(
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
              onTap: roster.status == RosterStatus.open
                  ? () {
                      final newStatus = student.status == AttendanceStatus.absent
                          ? AttendanceStatus.present
                          : AttendanceStatus.absent;
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
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'present'.tr;
      case AttendanceStatus.absent:
        return 'absent'.tr;
      case AttendanceStatus.late:
        return 'late'.tr;
      case AttendanceStatus.excused:
        return 'excused'.tr;
    }
  }
} 