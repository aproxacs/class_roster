import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/roster.dart';
import '../controllers/roster_controller.dart';
import '../models/roster.dart' as roster_model;

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
                  color: currentRoster.status == roster_model.RosterStatus.open
                      ? Colors.blue
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentRoster.status == roster_model.RosterStatus.open
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
            if (currentRoster.status == roster_model.RosterStatus.open) {
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
                          value: 'name',
                          child: Text('이름'),
                        ),
                        DropdownMenuItem(
                          value: 'studentId',
                          child: Text('학번'),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getStatusGradient(student.status),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: roster.status == roster_model.RosterStatus.open
                              ? () {
                                  final newStatus = student.status == roster_model.AttendanceStatus.absent
                                      ? roster_model.AttendanceStatus.present
                                      : roster_model.AttendanceStatus.absent;
                                  controller.updateStudentStatus(student, newStatus);
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (student.studentId != null) ...[
                                  const SizedBox(height: 4),
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
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusText(student.status),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
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

  List<Color> _getStatusGradient(roster_model.AttendanceStatus status) {
    switch (status) {
      case roster_model.AttendanceStatus.present:
        return [
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
        ];
      case roster_model.AttendanceStatus.absent:
        return [
          const Color(0xFFF44336),
          const Color(0xFFC62828),
        ];
      case roster_model.AttendanceStatus.late:
        return [
          const Color(0xFFFF9800),
          const Color(0xFFEF6C00),
        ];
      case roster_model.AttendanceStatus.excused:
        return [
          const Color(0xFF2196F3),
          const Color(0xFF1565C0),
        ];
    }
  }
} 