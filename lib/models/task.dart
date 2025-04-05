import 'package:flutter/material.dart';

class Task {
  final int? id;
  String title;
  String description;
  DateTime date;
  int estimatedPomodoros;
  int completedPomodoros;
  bool isCompleted;
  Color color;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.estimatedPomodoros,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    this.color = Colors.red,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted ? 1 : 0,
      'color': color.value,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      estimatedPomodoros: map['estimatedPomodoros'],
      completedPomodoros: map['completedPomodoros'],
      isCompleted: map['isCompleted'] == 1,
      color: Color(map['color']),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    Color? color,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
    );
  }
}
