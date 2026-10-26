import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyflow_ia/studyflow/services/studyflow_api.dart';

void main() {
  test('convierte el catálogo remoto en modelos de dominio', () async {
    final client = MockClient((request) async => http.Response(jsonEncode({
      'items': [
        {'id': '1', 'title': 'Pomodoro', 'category': 'Enfoque',
          'description': 'Sesiones breves', 'minutes': 25}
      ]
    }), 200, headers: {'content-type': 'application/json'}));
    final items = await StudyFlowApi(client: client).resources();
    expect(items, hasLength(1));
    expect(items.single.title, 'Pomodoro');
  });

  test('conserva el mensaje y código de un error autorizado', () async {
    final client = MockClient((request) async =>
      http.Response(jsonEncode({'message': 'Sesión caducada.'}), 401));
    expect(
      () => StudyFlowApi(client: client).tasks('token-no-real'),
      throwsA(isA<ApiFailure>()
        .having((failure) => failure.statusCode, 'statusCode', 401)
        .having((failure) => failure.message, 'message', 'Sesión caducada.')),
    );
  });
}
