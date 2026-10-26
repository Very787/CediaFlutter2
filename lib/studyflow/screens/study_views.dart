import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/studyflow_controllers.dart';
import '../models/study_models.dart';

class StatePanel extends StatelessWidget {
  const StatePanel({super.key, required this.icon, required this.title, this.detail, this.action});
  final IconData icon; final String title; final String? detail; final VoidCallback? action;
  @override Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12), Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
      if (detail != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(detail!, textAlign: TextAlign.center)),
      if (action != null) Padding(padding: const EdgeInsets.only(top: 16), child: FilledButton.tonal(onPressed: action, child: const Text('Reintentar'))),
    ]),
  ));
}

class TasksView extends StatefulWidget { const TasksView({super.key}); @override State<TasksView> createState() => _TasksViewState(); }
class _TasksViewState extends State<TasksView> {
  final controller = Get.find<TasksController>();
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => controller.load()); }
  @override Widget build(BuildContext context) => Obx(() {
    final body = switch (controller.state.value) {
      LoadState.loading => const Center(child: CircularProgressIndicator()),
      LoadState.error => StatePanel(icon: Icons.cloud_off, title: 'No pudimos cargar tu plan', detail: controller.error.value, action: controller.load),
      LoadState.empty => const StatePanel(icon: Icons.task_alt, title: 'Tu plan está vacío', detail: 'Agrega tu primera actividad de estudio.'),
      _ => ListView.builder(padding: const EdgeInsets.only(bottom: 96), itemCount: controller.items.length,
        itemBuilder: (_, index) { final task = controller.items[index]; return Card(child: ListTile(
          leading: Checkbox(value: task.completed, onChanged: (_) => controller.toggle(task)),
          title: Text(task.title, style: TextStyle(decoration: task.completed ? TextDecoration.lineThrough : null)),
          subtitle: Text('${task.subject} · ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}'),
          trailing: IconButton(tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline), onPressed: () => controller.remove(task.id)),
        )); }),
    };
    return Stack(children: [body, Positioned(right: 20, bottom: 20, child: FloatingActionButton.extended(
      onPressed: () => showDialog(context: context, builder: (_) => const TaskDialog()),
      icon: const Icon(Icons.add), label: const Text('Actividad')))]);
  });
}

class TaskDialog extends StatefulWidget { const TaskDialog({super.key}); @override State<TaskDialog> createState() => _TaskDialogState(); }
class _TaskDialogState extends State<TaskDialog> {
  final title = TextEditingController(); final subject = TextEditingController(); final key = GlobalKey<FormState>();
  @override void dispose() { title.dispose(); subject.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('Nueva actividad'), content: Form(key: key,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Actividad'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Campo requerido' : null),
      const SizedBox(height: 12), TextFormField(controller: subject, decoration: const InputDecoration(labelText: 'Materia'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Campo requerido' : null),
    ])), actions: [TextButton(onPressed: Get.back, child: const Text('Cancelar')), FilledButton(onPressed: () async {
      if (!key.currentState!.validate()) return;
      final ok = await Get.find<TasksController>().save(StudyTask(id: '', title: title.text.trim(), subject: subject.text.trim(), dueDate: DateTime.now().add(const Duration(days: 1)), completed: false));
      if (ok) Get.back();
    }, child: const Text('Guardar'))]);
}

class ResourcesView extends GetView<ResourcesController> {
  const ResourcesView({super.key});
  @override Widget build(BuildContext context) => Obx(() => switch (controller.state.value) {
    LoadState.loading => const Center(child: CircularProgressIndicator()),
    LoadState.error => StatePanel(icon: Icons.wifi_off, title: 'Recursos no disponibles', detail: controller.error.value, action: controller.load),
    LoadState.empty => const StatePanel(icon: Icons.library_books_outlined, title: 'No hay recursos todavía'),
    _ => RefreshIndicator(onRefresh: controller.load, child: ListView.builder(itemCount: controller.items.length,
      itemBuilder: (_, index) { final item = controller.items[index]; final favorite = controller.favorites.contains(item.id);
        return Card(child: ListTile(contentPadding: const EdgeInsets.all(16),
          title: Text(item.title), subtitle: Text('${item.category} · ${item.minutes} min\n${item.description}'), isThreeLine: true,
          trailing: IconButton(tooltip: favorite ? 'Quitar favorito' : 'Guardar favorito', onPressed: () => controller.toggle(item.id),
            icon: Icon(favorite ? Icons.bookmark : Icons.bookmark_border)))); })),
  });
}

class AssistantView extends StatefulWidget { const AssistantView({super.key}); @override State<AssistantView> createState() => _AssistantViewState(); }
class _AssistantViewState extends State<AssistantView> {
  final prompt = TextEditingController(); final controller = Get.find<AssistantController>();
  @override void dispose() { prompt.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Text('Planificador inteligente', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8), const Text('Indica tus materias, entregas y horas disponibles. La solicitud viaja al servidor; la app nunca contiene una clave de IA.'),
    const SizedBox(height: 20), TextField(controller: prompt, minLines: 4, maxLines: 7,
      decoration: const InputDecoration(labelText: '¿Qué necesitas organizar?', hintText: 'Tengo examen de matemáticas el viernes...')),
    const SizedBox(height: 12), Obx(() => FilledButton.icon(onPressed: controller.loading.value ? null : () => controller.ask(prompt.text),
      icon: controller.loading.value ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: const Text('Crear mi plan'))),
    Obx(() => controller.error.value == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 16), child: Text(controller.error.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
    Obx(() => controller.answer.value.isEmpty ? const SizedBox.shrink() : Card(child: Padding(padding: const EdgeInsets.all(20), child: SelectableText(controller.answer.value)))),
  ]);
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    CircleAvatar(radius: 42, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.person, size: 44)),
    const SizedBox(height: 16), Text('Tu espacio de estudio', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 8), const Text('El token de sesión se conserva en el almacenamiento seguro del dispositivo.', textAlign: TextAlign.center),
    const SizedBox(height: 24), OutlinedButton.icon(onPressed: () => Get.find<AuthController>().logout(), icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')),
  ])));
}
