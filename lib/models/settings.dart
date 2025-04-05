class PomodoroSettings {
  final int focusDuration; // 专注时长（分钟）
  final int shortBreakDuration; // 短休息时长（分钟）
  final int longBreakDuration; // 长休息时长（分钟）
  final int longBreakInterval; // 长休息间隔（完成几个番茄钟后进行长休息）
  final bool autoStartBreaks; // 自动开始休息
  final bool autoStartPomodoros; // 休息结束后自动开始下一个番茄钟
  final bool soundEnabled; // 声音开关
  final bool vibrationEnabled; // 震动开关
  final bool notificationsEnabled; // 通知开关
  final bool darkMode; // 暗黑模式

  PomodoroSettings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.darkMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'focusDuration': focusDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
    };
  }

  static PomodoroSettings fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      focusDuration: map['focusDuration'] ?? 25,
      shortBreakDuration: map['shortBreakDuration'] ?? 5,
      longBreakDuration: map['longBreakDuration'] ?? 15,
      longBreakInterval: map['longBreakInterval'] ?? 4,
      autoStartBreaks: map['autoStartBreaks'] ?? false,
      autoStartPomodoros: map['autoStartPomodoros'] ?? false,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkMode: map['darkMode'] ?? false,
    );
  }

  PomodoroSettings copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    bool? darkMode,
  }) {
    return PomodoroSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  // 从JSON创建
  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      focusDuration: json['focusDuration'] as int? ?? 25,
      shortBreakDuration: json['shortBreakDuration'] as int? ?? 5,
      longBreakDuration: json['longBreakDuration'] as int? ?? 15,
      longBreakInterval: json['longBreakInterval'] as int? ?? 4,
      autoStartBreaks: json['autoStartBreaks'] as bool? ?? false,
      autoStartPomodoros: json['autoStartPomodoros'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'focusDuration': focusDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
    };
  }
}
