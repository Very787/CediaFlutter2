import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/studyflow_controllers.dart';
import 'login_screen.dart';
import 'study_shell.dart';

class AuthGate extends GetView<AuthController> {
  const AuthGate({super.key});
  @override Widget build(BuildContext context) => Obx(() {
    if (controller.loading.value) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return controller.isAuthenticated ? const StudyShell() : const LoginScreen();
  });
}
