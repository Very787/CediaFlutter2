class StudyResource {
  const StudyResource({required this.id, required this.title, required this.category,
    required this.description, required this.minutes});
  final String id;
  final String title;
  final String category;
  final String description;
  final int minutes;

  factory StudyResource.fromJson(Map<String, dynamic> json) => StudyResource(
    id: json['id'].toString(), title: json['title'] as String,
    category: json['category'] as String, description: json['description'] as String,
    minutes: json['minutes'] as int,
  );
}

class StudyTask {
  const StudyTask({required this.id, required this.title, required this.subject,
    required this.dueDate, required this.completed});
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final bool completed;

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
    id: json['id'].toString(), title: json['title'] as String,
    subject: json['subject'] as String, dueDate: DateTime.parse(json['dueDate'] as String),
    completed: json['completed'] as bool? ?? false,
  );
  Map<String, dynamic> toJson() => {'title': title, 'subject': subject,
    'dueDate': dueDate.toIso8601String(), 'completed': completed};
  StudyTask copyWith({bool? completed}) => StudyTask(id: id, title: title,
    subject: subject, dueDate: dueDate, completed: completed ?? this.completed);
}
