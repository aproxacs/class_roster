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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '출석부',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: '학생 그룹',
            ),
          ],
        ),
      ),
    );
  }
} 