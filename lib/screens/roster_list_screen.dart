import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tr_app/controllers/roster_list_controller.dart';
import 'package:tr_app/screens/attendance_screen.dart';

class RosterListScreen extends StatefulWidget {
  @override
  _RosterListScreenState createState() => _RosterListScreenState();
}

class _RosterListScreenState extends State<RosterListScreen> {
  final RosterListController controller = Get.put(RosterListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출석부 목록'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRosterDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.rosters.isEmpty) {
          return Center(
            child: Text('출석부가 없습니다'.tr),
          );
        }

        return ListView.builder(
          itemCount: controller.rosters.length,
          itemBuilder: (context, index) {
            final roster = controller.rosters[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(roster.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${roster.startTime} ~ ${roster.endTime ?? '진행중'}'),
                    Text('${roster.presentCount}명 출석 / ${roster.absentCount}명 결석'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (roster.status == 'completed')
                      IconButton(
                        icon: const Icon(Icons.refresh),
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
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(roster),
                    ),
                  ],
                ),
                onTap: () {
                  controller.selectRoster(roster);
                  Get.to(() => AttendanceScreen());
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showCreateRosterDialog() {
    // Implementation of _showCreateRosterDialog method
  }

  void _showDeleteConfirmation(Roster roster) {
    // Implementation of _showDeleteConfirmation method
  }
} 