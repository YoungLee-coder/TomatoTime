// import 'package:flutter/foundation.dart';

class PomodoroHistory {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // 单位：分钟
  final String? taskId;
  final String
  status; // 'completed', 'interrupted', 'abandoned', 'break_completed'
  final String? note;

  PomodoroHistory({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.taskId,
    required this.status,
    this.note,
  });

  factory PomodoroHistory.fromJson(Map<String, dynamic> json) {
    return PomodoroHistory(
      id: json['id'].toString(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: json['duration'] as int,
      taskId: json['taskId']?.toString(),
      status: json['status'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'taskId': taskId,
      'status': status,
      'note': note,
    };
  }

  // 为向后兼容添加的方法
  factory PomodoroHistory.fromMap(Map<String, dynamic> map) {
    return PomodoroHistory(
      id: map['id'].toString(),
      startTime:
          map['startTime'] is String
              ? DateTime.parse(map['startTime'] as String)
              : map['startTime'] as DateTime,
      endTime:
          map['endTime'] is String
              ? DateTime.parse(map['endTime'] as String)
              : map['endTime'] as DateTime,
      duration: map['duration'] as int,
      taskId: map['taskId']?.toString(),
      status: map['status'] as String,
      note: map['note'] as String?,
    );
  }

  // 为向后兼容添加的方法
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'taskId': taskId,
      'status': status,
      'note': note,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PomodoroHistory &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.duration == duration &&
        other.taskId == taskId &&
        other.status == status &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        duration.hashCode ^
        taskId.hashCode ^
        status.hashCode ^
        note.hashCode;
  }
}
