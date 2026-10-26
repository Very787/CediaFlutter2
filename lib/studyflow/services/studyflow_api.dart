import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/study_models.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override String toString() => message;
}

class StudyFlowApi {
  StudyFlowApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<Map<String, dynamic>> _send(String method, String path,
      {String? token, Map<String, dynamic>? body}) async {
    try {
      final request = http.Request(method, _uri(path));
      request.headers['content-type'] = 'application/json';
      if (token != null) request.headers['authorization'] = 'Bearer $token';
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client.send(request).timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiFailure(decoded['message'] as String? ?? _messageFor(response.statusCode),
          statusCode: response.statusCode);
      }
      return decoded;
    } on ApiFailure { rethrow; }
      on SocketException { throw const ApiFailure('No se pudo conectar con el servidor.'); }
      on http.ClientException { throw const ApiFailure('No se pudo completar la solicitud.'); }
      on FormatException { throw const ApiFailure('El servidor devolvió una respuesta inválida.'); }
  }

  String _messageFor(int code) => switch (code) {
    400 => 'La solicitud contiene datos inválidos.',
    401 => 'La sesión no es válida. Vuelve a iniciar sesión.',
    422 => 'Revisa los campos ingresados.',
    >= 500 => 'El servidor tuvo un problema. Intenta más tarde.',
    _ => 'No se pudo completar la solicitud.',
  };

  Future<String> authenticate(String email, String password, {required bool register}) async {
    final json = await _send('POST', register ? '/auth/register' : '/auth/login',
      body: {'email': email, 'password': password});
    return json['token'] as String;
  }
  Future<List<StudyResource>> resources() async {
    final json = await _send('GET', '/resources');
    return (json['items'] as List).cast<Map<String, dynamic>>().map(StudyResource.fromJson).toList();
  }
  Future<List<StudyTask>> tasks(String token) async {
    final json = await _send('GET', '/tasks', token: token);
    return (json['items'] as List).cast<Map<String, dynamic>>().map(StudyTask.fromJson).toList();
  }
  Future<StudyTask> saveTask(String token, StudyTask task) async {
    final isNew = task.id.isEmpty;
    final json = await _send(isNew ? 'POST' : 'PUT', isNew ? '/tasks' : '/tasks/${task.id}',
      token: token, body: task.toJson());
    return StudyTask.fromJson(json['item'] as Map<String, dynamic>);
  }
  Future<void> deleteTask(String token, String id) async {
    await _send('DELETE', '/tasks/$id', token: token);
  }
  Future<String> plan(String token, String prompt) async {
    final json = await _send('POST', '/ai/plan', token: token, body: {'prompt': prompt});
    return json['answer'] as String;
  }
}
