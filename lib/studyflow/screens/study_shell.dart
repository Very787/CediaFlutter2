import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/studyflow_controllers.dart';
import 'study_views.dart';

class StudyShell extends GetView<NavigationController> {
  const StudyShell({super.key});
  static const views = [TasksView(), ResourcesView(), AssistantView(), ProfileView()];
  @override Widget build(BuildContext context) => Obx(() => Scaffold(
    appBar: AppBar(title: const Text('StudyFlow IA')),
    body: IndexedStack(index: controller.index.value, children: views),
    bottomNavigationBar: NavigationBar(
      selectedIndex: controller.index.value,
      onDestinationSelected: (value) {
        controller.index.value = value;
        if (value == 0) Get.find<TasksController>().load();
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.checklist), label: 'Plan'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Recursos'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Asistente'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    ),
  ));
}
