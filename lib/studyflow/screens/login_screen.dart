import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/studyflow_controllers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  final formKey = GlobalKey<FormState>();
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(
        key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Icon(Icons.auto_stories_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('StudyFlow IA', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
          const Text('Convierte tus pendientes en un plan posible.', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) => v != null && v.contains('@') ? null : 'Ingresa un correo válido'),
          const SizedBox(height: 12),
          TextFormField(controller: password, obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
            validator: (v) => (v?.length ?? 0) >= 8 ? null : 'Usa al menos 8 caracteres'),
          const SizedBox(height: 16),
          Obx(() => auth.error.value == null ? const SizedBox.shrink() : Padding(
            padding: const EdgeInsets.only(bottom: 12), child: Text(auth.error.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)))),
          Obx(() => FilledButton.icon(
            onPressed: auth.loading.value ? null : () async {
              if (!formKey.currentState!.validate()) return;
              await auth.submit(email.text, password.text, register: register);
            }, icon: auth.loading.value ? const SizedBox.square(dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
            label: Text(register ? 'Crear cuenta' : 'Iniciar sesión'))),
          TextButton(onPressed: () => setState(() => register = !register),
            child: Text(register ? 'Ya tengo una cuenta' : 'Crear una cuenta nueva')),
        ]),
      )),
    ))));
  }
}
