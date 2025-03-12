import 'package:get/get.dart';
import '../models/student_group.dart';
import '../services/database_service.dart';

class StudentGroupController extends GetxController {
  final _groups = <StudentGroup>[].obs;
  final _selectedGroup = Rxn<StudentGroup>();
  final _groupStudentCounts = <int, int>{}.obs;

  List<StudentGroup> get groups => _groups;
  StudentGroup? get selectedGroup => _selectedGroup.value;
  int getStudentCount(int groupId) => _groupStudentCounts[groupId] ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    final groups = await DatabaseService.instance.getAllStudentGroups();
    _groups.assignAll(groups);
    
    // 각 그룹의 학생 수를 로드합니다
    for (final group in groups) {
      if (group.id != null) {
        final count = await DatabaseService.instance.getStudentCountByGroup(group.id!);
        _groupStudentCounts[group.id!] = count;
      }
    }
    _groupStudentCounts.refresh();
  }

  Future<void> addGroup(String name, {String? description}) async {
    final group = StudentGroup(
      name: name,
      description: description,
    );
    final savedGroup = await DatabaseService.instance.createStudentGroup(group);
    _groups.add(savedGroup);
  }

  Future<void> updateGroup(StudentGroup group) async {
    await DatabaseService.instance.updateStudentGroup(group);
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      _groups.refresh();
    }
  }

  Future<void> deleteGroup(int id) async {
    await DatabaseService.instance.deleteStudentGroup(id);
    _groups.removeWhere((group) => group.id == id);
    if (selectedGroup?.id == id) {
      _selectedGroup.value = null;
    }
  }

  void selectGroup(StudentGroup group) {
    _selectedGroup.value = group;
  }
} 