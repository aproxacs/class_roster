import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_group_controller.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentGroupController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 그룹'),
        centerTitle: true,
      ),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                title: Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (group.description != null && group.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(group.description!),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${controller.getStudentCount(group.id!)}명',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('그룹 삭제'),
                        content: const Text('이 그룹을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteGroup(group.id!);
                              Get.back();
                            },
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () {
                  controller.selectGroup(group);
                  Get.to(() => GroupDetailScreen(group: group));
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameController = TextEditingController();
          final descController = TextEditingController();
          
          Get.dialog(
            AlertDialog(
              title: const Text('새 그룹 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '그룹 이름',
                    ),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: '설명 (선택사항)',
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
                      controller.addGroup(
                        nameController.text,
                        description: descController.text.isEmpty
                            ? null
                            : descController.text,
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
        child: const Icon(Icons.add),
      ),
    );
  }
} 