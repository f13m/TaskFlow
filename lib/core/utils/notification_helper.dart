import '../../features/tasks/data/models/task_model.dart';

class NotificationHelper {
    
  // حساب معرف فريد للإشعار (نسخة آمنة)
    
static int getNotificationId(String taskId, int typeCode) {
  int rawId = taskId.hashCode.abs();
  int safeId = (rawId % 10000000) * 100 + typeCode;
  // التأكد النهائي من عدم تجاوز الحد
  if (safeId > 2147483647) {
    safeId = safeId % 2147483647;
  }
  
  return safeId.abs();
}

    
  // التحقق من صحة المهمة للجدولة
    
  static bool isTaskValidForNotifications(TaskModel task) {
    if (task.startTime == null) return false;
    
    final now = DateTime.now();
    final startTime = task.startTime!;
    
    // مهمة منتهية منذ أكثر من يوم
    if (startTime.isBefore(now.subtract(const Duration(days: 1)))) {
      return false;
    }
    
    // مهمة بعد أكثر من سنة (لا نحتاج إشعارات الآن)
    if (startTime.isAfter(now.add(const Duration(days: 365)))) {
      return false;
    }
    
    return true;
  }

    
  // الحصول على قائمة تواريخ الإشعارات (نسخة محسنة)
    
  static List<DateTime> getNotificationTimes(TaskModel task) {
    final List<DateTime> times = [];
    final now = DateTime.now();
    
    if (!isTaskValidForNotifications(task)) return times;
    
    final startTime = task.startTime!;
    final endTime = task.endTime ?? startTime.add(const Duration(hours: 1));
    
    switch (task.priority) {
      case TaskPriority.high:
        _addIfFuture(now, times, startTime.subtract(const Duration(days: 1)));
        _addIfFuture(now, times, startTime.subtract(const Duration(hours: 1)));
        _addIfFuture(now, times, startTime.subtract(const Duration(minutes: 5)));
        _addIfFuture(now, times, endTime.subtract(const Duration(minutes: 10))); // بدلاً من بعد الانتهاء
        break;
        
      case TaskPriority.medium:
        _addIfFuture(now, times, startTime.subtract(const Duration(days: 1)));
        _addIfFuture(now, times, startTime.subtract(const Duration(minutes: 30)));
        _addIfFuture(now, times, startTime.subtract(const Duration(minutes: 5)));
        break;
        
      case TaskPriority.low:
        _addIfFuture(now, times, startTime.subtract(const Duration(minutes: 30)));
        _addIfFuture(now, times, startTime.subtract(const Duration(minutes: 5)));
        break;
    }
    
    return times;
  }

  // دالة مساعدة لإضافة التاريخ فقط إذا كان مستقبلياً
  static void _addIfFuture(DateTime now, List<DateTime> times, DateTime date) {
    if (date.isAfter(now)) {
      times.add(date);
    }
  }

    
  // الحصول على نص الإشعار (نسخة محسنة باستخدام difference)
    
  static String getNotificationBody(DateTime notificationTime, TaskModel task) {
    final startTime = task.startTime!;
    final endTime = task.endTime ?? startTime.add(const Duration(hours: 1));
    
    final diffDaysFromStart = notificationTime.difference(startTime).inDays;
    final diffHoursFromStart = notificationTime.difference(startTime).inHours;
    final diffMinutesFromStart = notificationTime.difference(startTime).inMinutes;
    final diffMinutesFromEnd = notificationTime.difference(endTime).inMinutes;
    
    if (diffDaysFromStart == -1) {
      return '⏰ "${task.title}" مستحقة غداً! جهز نفسك.';
    }
    if (diffHoursFromStart == -1) {
      return '⚡ "${task.title}" بعد ساعة! استعد.';
    }
    if (diffMinutesFromStart == -30) {
      return '🕐 "${task.title}" بعد نصف ساعة.';
    }
    if (diffMinutesFromStart == -5) {
      return '🔥 "${task.title}" بعد 5 دقائق! جهز نفسك الآن.';
    }
    if (diffMinutesFromEnd == -10) {
      return '⏳ "${task.title}" تنتهي بعد 10 دقائق. هل انتهيت؟';
    }
    if (diffMinutesFromEnd == -5) {
      return '⚠️ "${task.title}" تنتهي بعد 5 دقائق! أسرع.';
    }
    
    return '🔔 تذكير: "${task.title}"';
  }

    
  // الحصول على جميع معرفات الإشعارات لمهمة (لحذفها بسهولة)
    
  static List<int> getAllNotificationIdsForTask(String taskId, int maxNotifications) {
    final List<int> ids = [];
    for (int i = 0; i < maxNotifications; i++) {
      ids.add(getNotificationId(taskId, i));
    }
    return ids;
  }
}