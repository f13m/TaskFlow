import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt;
  
    
  //    إضافات جديدة: وقت البدء ووقت الانتهاء
    
  final DateTime? startTime;  // وقت بدء المهمة (اختياري)
  final DateTime? endTime;    // وقت انتهاء المهمة (اختياري)

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.completedAt,
    this.startTime,      //   جديد
    this.endTime,        //   جديد
  });

    
  // دالة copyWith لتعديل نسخة من المهمة
    
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? startTime,    //   جديد
    DateTime? endTime,      //   جديد
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

    
  // حساب مدة المهمة (الفارق بين وقت البدء والانتهاء)
    
  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

    
  // نص منسق لعرض الوقت (مثال: "10:00 AM - 12:00 PM")
    
  String get formattedTimeRange {
    if (startTime == null && endTime == null) {
      return 'No time set';
    }
    
    final start = startTime != null 
        ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
        : '??:??';
    
    final end = endTime != null 
        ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
        : '??:??';
    
    return '$start - $end';
  }

    
  // تحويل الكائن إلى Map (للتخزين في SharedPreferences أو Firebase)
    
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),   //   جديد
      'endTime': endTime?.toIso8601String(),       //   جديد
    };
  }

    
  // إنشاء كائن من Map (من SharedPreferences أو Firebase)
    
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : null,
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'])
          : null,
    );
  }

    
  // بيانات وهمية للاختبار (Mock Data)
    
  static List<TaskModel> getMockTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final upcoming = today.add(const Duration(days: 5));
    final yesterday = today.subtract(const Duration(days: 1));
    
    // أمثلة مع وقت البدء والانتهاء
    final startTimeExample = DateTime(today.year, today.month, today.day, 10, 0);  // 10:00 AM
    final endTimeExample = DateTime(today.year, today.month, today.day, 12, 0);     // 12:00 PM

    return [
      TaskModel(
        id: '1',
        title: 'Overdue: Submit project',
        description: 'This task was due yesterday',
        dueDate: yesterday,
        priority: TaskPriority.high,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: '2',
        title: 'Today: Team meeting',
        dueDate: today,
        priority: TaskPriority.high,
        createdAt: now.subtract(const Duration(days: 1)),
        startTime: startTimeExample,
        endTime: endTimeExample,
      ),
      TaskModel(
        id: '3',
        title: 'Tomorrow: Review documentation',
        dueDate: tomorrow,
        priority: TaskPriority.medium,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '4',
        title: 'Upcoming: Read Flutter article',
        dueDate: upcoming,
        priority: TaskPriority.low,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TaskModel(
        id: '5',
        title: 'Today: Prepare presentation',
        dueDate: today,
        priority: TaskPriority.medium,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '6',
        title: 'Tomorrow: Client meeting prep',
        dueDate: tomorrow,
        priority: TaskPriority.high,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}