import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_ia/studyflow/models/study_models.dart';

void main() {
  test('StudyTask conserva el contrato JSON del servidor', () {
    final task = StudyTask(id: 't1', title: 'Repasar', subject: 'Matemáticas',
      dueDate: DateTime.utc(2026, 10, 27), completed: false);
    final restored = StudyTask.fromJson({'id': task.id, ...task.toJson()});
    expect(restored.title, 'Repasar');
    expect(restored.completed, isFalse);
    expect(restored.dueDate, DateTime.utc(2026, 10, 27));
  });

  test('copyWith solo modifica el estado completado', () {
    final task = StudyTask(id: '1', title: 'Leer', subject: 'Historia',
      dueDate: DateTime.utc(2026), completed: false);
    final completed = task.copyWith(completed: true);
    expect(completed.completed, isTrue);
    expect(completed.title, task.title);
  });
}
