import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/roster_controller.dart';
import '../models/roster.dart';
import '../models/student.dart';

class AttendanceScreen extends StatelessWidget {
  final Roster roster;
  final RxString sortBy = 'name'.obs;

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
        title: Obx(() {
          final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(roster.title),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentRoster.status == RosterStatus.open
                      ? Colors.blue
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentRoster.status == RosterStatus.open
                      ? '진행 중'
                      : '종료됨',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
        centerTitle: false,
        actions: [
          Obx(() {
            final currentRoster = controller.rosters.firstWhere((r) => r.id == roster.id);
            if (currentRoster.status == RosterStatus.open) {
              return TextButton.icon(
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
                icon: const Icon(Icons.check),
                label: Text('close'.tr),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              );
            }
            if (currentRoster.status == RosterStatus.closed) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('출석부 다시 시작'.tr),
                          content: Text('이 출석부를 다시 시작하시겠습니까?'.tr),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('취소'.tr),
                            ),
                            TextButton(
                              onPressed: () async {
                                await controller.restartRoster(roster.id!);
                                Get.back();
                              },
                              child: Text('확인'.tr),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
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
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('도움말'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• 학생을 터치해서 출석/결석 상태를 바꿀 수 있습니다.'),
                            const SizedBox(height: 8),
                            const Text('• 결석한 학생을 길게 터치해서 전화를 걸 수 있습니다.'),
                            const SizedBox(height: 8),
                            const Text('• 상단의 정렬 버튼으로 학생 목록을 정렬할 수 있습니다.'),
                            const SizedBox(height: 8),
                            const Text('• 출석부가 진행 중일 때만 상태를 변경할 수 있습니다.'),
                            const SizedBox(height: 8),
                            const Text('• 출석부가 종료되면 CSV 파일로 내보낼 수 있습니다.'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('닫기'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Text(
                      '정렬: ',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Obx(() => DropdownButton<String>(
                      value: sortBy.value,
                      items: const [
                        DropdownMenuItem(
                          value: 'studentId',
                          child: Text('학번'),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('이름'),
                        ),
                        DropdownMenuItem(
                          value: 'status',
                          child: Text('출석상태'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          sortBy.value = value;
                        }
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final students = controller.rosterStudents;
              if (students.isEmpty) {
                return Center(
                  child: Text('no_students'.tr),
                );
              }

              final sortedStudents = [...students];
              switch (sortBy.value) {
                case 'name':
                  sortedStudents.sort((a, b) => a.name.compareTo(b.name));
                  break;
                case 'studentId':
                  sortedStudents.sort((a, b) {
                    final aId = a.studentId ?? '';
                    final bId = b.studentId ?? '';
                    return aId.compareTo(bId);
                  });
                  break;
                case 'status':
                  sortedStudents.sort((a, b) => a.status.index.compareTo(b.status.index));
                  break;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: sortedStudents.length,
                itemBuilder: (context, index) {
                  final student = sortedStudents[index];
                  return _buildStudentCard(student);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(RosterStudent student) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: student.status == AttendanceStatus.present
                ? [Colors.green.shade300, Colors.green.shade500]
                : [Colors.red.shade300, Colors.red.shade500],
          ),
        ),
        child: InkWell(
          onTap: () => _toggleAttendance(student),
          onLongPress: () => _showCallDialog(student),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.studentId ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (student.status == AttendanceStatus.absent && student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
                            const Icon(
                              Icons.phone,
                              color: Colors.white70,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.status == AttendanceStatus.present ? '출석' : '결석',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAttendance(RosterStudent student) {
    final controller = Get.find<RosterController>();
    final newStatus = student.status == AttendanceStatus.present 
        ? AttendanceStatus.absent 
        : AttendanceStatus.present;
    controller.updateStudentStatus(student, newStatus);
  }

  void _showCallDialog(RosterStudent student) {
    if (student.status == AttendanceStatus.absent && student.phoneNumber != null && student.phoneNumber!.isNotEmpty) {
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
  }
} 