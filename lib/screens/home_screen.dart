import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_group_controller.dart';
import 'group_list_screen.dart';
import 'attendance_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = 0.obs;
    final screens = [
      const AttendanceHistoryScreen(),
      const GroupListScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: selectedIndex.value,
          onTap: (index) => selectedIndex.value = index,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: 'attendance'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              label: 'student_groups'.tr,
            ),
          ],
        ),
      ),
    );
  }
} 