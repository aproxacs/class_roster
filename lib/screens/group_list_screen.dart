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
        title: Text('student_groups'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final nameController = TextEditingController();
              final descriptionController = TextEditingController();
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('new_group'.tr),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'group_name'.tr,
                          hintText: 'group_name'.tr,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description_optional'.tr,
                          hintText: 'description_optional'.tr,
                        ),
                        maxLines: 3,
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
                            'notification'.tr,
                            'enter_student_name_error'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        
                        controller.addGroup(
                          nameController.text,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
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
                title: Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (group.description != null)
                      Text(group.description!),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'student_count'.trParams({'count': controller.getStudentCount(group.id!).toString()}),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        )),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('delete_group'.tr),
                        content: Text('delete_group_confirm'.tr),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('cancel'.tr),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteGroup(group.id!);
                              Get.back();
                            },
                            child: Text(
                              'delete'.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () {
                  Get.to(() => GroupDetailScreen(group: group));
                },
              ),
            );
          },
        ),
      ),
    );
  }
} 