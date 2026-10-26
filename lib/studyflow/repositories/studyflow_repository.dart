import '../models/study_models.dart';
import '../services/local_store.dart';
import '../services/studyflow_api.dart';

class StudyFlowRepository {
  StudyFlowRepository(this.api, this.local);
  final StudyFlowApi api;
  final LocalStore local;
  Future<String?> restoreToken() => local.readToken();
  Future<String> login(String email, String password, {bool register = false}) async {
    final token = await api.authenticate(email, password, register: register);
    await local.writeToken(token); return token;
  }
  Future<void> logout() => local.clearToken();
  Future<List<StudyResource>> resources() => api.resources();
  Future<List<StudyTask>> tasks(String token) => api.tasks(token);
  Future<StudyTask> saveTask(String token, StudyTask task) => api.saveTask(token, task);
  Future<void> deleteTask(String token, String id) => api.deleteTask(token, id);
  Future<String> plan(String token, String prompt) => api.plan(token, prompt);
  Set<String> favoriteIds() => local.favoriteIds();
  Future<void> toggleFavorite(String id) => local.toggleFavorite(id);
}
