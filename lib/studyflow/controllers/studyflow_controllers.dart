import 'package:get/get.dart';
import '../models/study_models.dart';
import '../repositories/studyflow_repository.dart';
import '../services/studyflow_api.dart';

enum LoadState { idle, loading, ready, empty, error }

class AuthController extends GetxController {
  AuthController(this.repository);
  final StudyFlowRepository repository;
  final token = RxnString();
  final loading = true.obs;
  final error = RxnString();
  bool get isAuthenticated => token.value != null;

  @override void onInit() { super.onInit(); restore(); }
  Future<void> restore() async {
    token.value = await repository.restoreToken(); loading.value = false;
  }
  Future<bool> submit(String email, String password, {required bool register}) async {
    loading.value = true; error.value = null;
    try {
      token.value = await repository.login(email.trim(), password, register: register);
      return true;
    } on ApiFailure catch (failure) { error.value = failure.message; return false; }
    finally { loading.value = false; }
  }
  Future<void> logout() async { await repository.logout(); token.value = null; }
}

class ResourcesController extends GetxController {
  ResourcesController(this.repository);
  final StudyFlowRepository repository;
  final items = <StudyResource>[].obs;
  final favorites = <String>{}.obs;
  final state = LoadState.idle.obs;
  final error = RxnString();
  @override void onInit() { super.onInit(); load(); }
  Future<void> load() async {
    state.value = LoadState.loading; error.value = null;
    try {
      items.assignAll(await repository.resources());
      favorites.assignAll(repository.favoriteIds());
      state.value = items.isEmpty ? LoadState.empty : LoadState.ready;
    } on ApiFailure catch (failure) { error.value = failure.message; state.value = LoadState.error; }
  }
  Future<void> toggle(String id) async {
    await repository.toggleFavorite(id); favorites.assignAll(repository.favoriteIds());
  }
}

class TasksController extends GetxController {
  TasksController(this.repository, this.auth);
  final StudyFlowRepository repository;
  final AuthController auth;
  final items = <StudyTask>[].obs;
  final state = LoadState.idle.obs;
  final error = RxnString();
  Future<void> load() async {
    final currentToken = auth.token.value; if (currentToken == null) return;
    state.value = LoadState.loading; error.value = null;
    try {
      items.assignAll(await repository.tasks(currentToken));
      state.value = items.isEmpty ? LoadState.empty : LoadState.ready;
    } on ApiFailure catch (failure) {
      error.value = failure.message; state.value = LoadState.error;
      if (failure.statusCode == 401) await auth.logout();
    }
  }
  Future<bool> save(StudyTask task) async {
    final currentToken = auth.token.value; if (currentToken == null) return false;
    try { await repository.saveTask(currentToken, task); await load(); return true; }
    on ApiFailure catch (failure) { error.value = failure.message; return false; }
  }
  Future<void> toggle(StudyTask task) => save(task.copyWith(completed: !task.completed));
  Future<void> remove(String id) async {
    final currentToken = auth.token.value; if (currentToken == null) return;
    try { await repository.deleteTask(currentToken, id); await load(); }
    on ApiFailure catch (failure) { error.value = failure.message; }
  }
}

class AssistantController extends GetxController {
  AssistantController(this.repository, this.auth);
  final StudyFlowRepository repository;
  final AuthController auth;
  final loading = false.obs;
  final answer = ''.obs;
  final error = RxnString();
  Future<void> ask(String prompt) async {
    if (prompt.trim().length < 10) { error.value = 'Describe materias, pendientes y tiempo disponible.'; return; }
    loading.value = true; error.value = null;
    try { answer.value = await repository.plan(auth.token.value!, prompt.trim()); }
    on ApiFailure catch (failure) { error.value = failure.message; }
    finally { loading.value = false; }
  }
}

class NavigationController extends GetxController { final index = 0.obs; }
