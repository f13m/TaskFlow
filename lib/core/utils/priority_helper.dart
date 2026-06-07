import 'package:flutter/material.dart';
import '../../features/tasks/data/models/task_model.dart';

enum TaskStatus {
  overdue,    // فات موعدها
  dueToday,   // اليوم
  dueTomorrow,// غداً
  upcoming,   // القادم
}

class PriorityHelper {
  // تحديد حالة المهمة
  static TaskStatus getTaskStatus(DateTime dueDate, bool isCompleted) {
   // if (isCompleted) return TaskStatus.completed;
    
    final now = DateTime.now();
    // تجاهل الوقت: نقارن فقط السنة والشهر واليوم
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (due.isBefore(today)) return TaskStatus.overdue;
    if (due == today) return TaskStatus.dueToday;
    if (due == tomorrow) return TaskStatus.dueTomorrow;
    return TaskStatus.upcoming;
  }
  
  // تحديد لون المهمة
  static Color getTaskColor(DateTime dueDate, bool isCompleted) {
  if (isCompleted) return const Color(0xFF42A5F5);  // أزرق فاتح جميل
  
  switch (getTaskStatus(dueDate, false)) {
    case TaskStatus.overdue:
      return const Color(0xFF9E9E9E);  // رمادي فاتح في الداكن
    case TaskStatus.dueToday:
      return const Color(0xFFFF5252);  // أحمر ناصع في الداكن
    case TaskStatus.dueTomorrow:
      return const Color(0xFFFFA726);  // برتقالي جميل
    case TaskStatus.upcoming:
      return const Color(0xFF66BB6A);  // أخضر زاهي
  }
}
  
  // النص الوصفي
  static String getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.overdue:
        return 'Overdue';
      case TaskStatus.dueToday:
        return 'Today';
      case TaskStatus.dueTomorrow:
        return 'Tomorrow';
      case TaskStatus.upcoming:
        return 'Upcoming';
            
    }
  }
      
  //    تمت الإضافة: دالة ترتيب المهام حسب الأولوية والتاريخ
    
  static List<TaskModel> sortTasksByPriority(List<TaskModel> tasks) {
    final List<TaskModel> sorted = List.from(tasks);
    sorted.sort((a, b) {
      // الخطوة 1: المهام غير المكتملة تظهر أولاً
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      // الخطوة 2: الترتيب حسب الأولوية (High ← Medium ← Low)
      final priorityOrder = {
        TaskPriority.high: 0,   // الأولوية العالية أولاً
        TaskPriority.medium: 1,
        TaskPriority.low: 2,
      };
      final priorityCompare = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityCompare != 0) return priorityCompare;
      
      // الخطوة 3: إذا تساوت الأولوية، نرتب حسب التاريخ الأقرب
      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }
}