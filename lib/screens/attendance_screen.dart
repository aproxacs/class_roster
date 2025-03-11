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
                  currentRoster.status == RosterStatus.open ? '진행 중' : '종료됨',
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
                      title: const Text('출석부 종료'),
                      content: const Text('출석부를 종료하시겠습니까?\n종료 후에는 수정할 수 없습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.closeRoster(roster);
                            Get.back();
                          },
                          child: const Text('종료'),
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
                    '알림',
                    'CSV 파일이 다운로드되었습니다.',
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
              child: Card(
                color: _getStatusColor(student.status),
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