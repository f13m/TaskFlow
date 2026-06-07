import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/task_model.dart';
import '../../../core/utils/priority_helper.dart';
import '../../../services/notification_service.dart';
import '../../../core/utils/notification_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  
  List<TaskModel> get tasks => _tasks;
  
    
  //   Constructor: تحميل البيانات عند بدء التطبيق
    
  TaskProvider() {
    loadTasksFromLocal();
  }
  
    
  //    حفظ المهام في SharedPreferences
    
  Future<void> saveTasksToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toMap()).toList();
    final jsonString = jsonEncode(tasksJson);
    await prefs.setString('tasks', jsonString);
    print('  تم حفظ ${_tasks.length} مهمة');
  }
  
    
  //    تحميل المهام من SharedPreferences
    
Future<void> loadTasksFromLocal() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('tasks');
  
  if (jsonString != null && jsonString.isNotEmpty) {
    final List<dynamic> tasksJson = jsonDecode(jsonString);
    _tasks = tasksJson.map((json) => TaskModel.fromMap(json, json['id'])).toList();
    print(' تم تحميل ${_tasks.length} مهمة من التخزين المحلي');
  } else {
    //  لا بيانات وهمية، نبدأ بقائمة فارغة
    _tasks = [];
    print(' لا توجد مهام مخزنة، نبدأ بقائمة فارغة');
  }
  notifyListeners();
}
  
  // الحصول على المهام حسب الحالة
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) {
      final taskStatus = PriorityHelper.getTaskStatus(task.dueDate, task.isCompleted);
      //if (task.isCompleted) return false;
      return taskStatus == status;
    }).toList();
  }
  
  // إضافة مهمة جديدة
  void addTask(TaskModel task) {
    _tasks.add(task);
    _tasks = PriorityHelper.sortTasksByPriority(_tasks);
    saveTasksToLocal();  //   حفظ بعد الإضافة
    _scheduleTaskNotifications(task);
    notifyListeners();
  }
  
  // تحديث مهمة
void updateTask(TaskModel updatedTask) {
  final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
  if (index != -1) {
    final oldTask = _tasks[index];
    _cancelTaskNotifications(oldTask);  //   إلغاء القديمة
    _tasks[index] = updatedTask;
    _tasks = PriorityHelper.sortTasksByPriority(_tasks);
    saveTasksToLocal();
    _scheduleTaskNotifications(updatedTask);  //   جدولة الجديدة
    notifyListeners();
  }
}
  
  // حذف مهمة
 void deleteTask(String taskId) {
  final task = _tasks.firstWhere((t) => t.id == taskId);
  _cancelTaskNotifications(task);  //   إضافة هذه السطر
  _tasks.removeWhere((task) => task.id == taskId);
  saveTasksToLocal();
  notifyListeners();
}
  
  // تبديل حالة الإكمال
void toggleCompletion(String taskId) {
  final index = _tasks.indexWhere((task) => task.id == taskId);
  if (index != -1) {
    final task = _tasks[index];
    // إذا اكتملت المهمة، نلغي إشعاراتها
    if (!task.isCompleted) {
      _cancelTaskNotifications(task);
    }
    
    _tasks[index] = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    _tasks = PriorityHelper.sortTasksByPriority(_tasks);
    saveTasksToLocal();
    notifyListeners();
  }
}
    
// جدولة إشعارات المهمة
  
Future<void> _scheduleTaskNotifications(TaskModel task) async {
  if (task.startTime == null) return;
  //   التحقق من تمكين الإشعارات
  final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
  if (!notificationsEnabled) return;
  
  final notificationTimes = NotificationHelper.getNotificationTimes(task);
  final notificationService = NotificationService();
  
  int typeCode = 0;
  for (final time in notificationTimes) {
    final id = NotificationHelper.getNotificationId(task.id, typeCode);
    final body = NotificationHelper.getNotificationBody(time, task);
    await notificationService.scheduleNotification(
      id: id,
      title: 'TaskFlow Reminder',
      body: body,
      scheduledDate: time,
    );
    typeCode++;
  }
}

  
// إلغاء إشعارات المهمة
  
Future<void> _cancelTaskNotifications(TaskModel task) async {
  final notificationService = NotificationService();
  
  // إلغاء جميع الإشعارات المرتبطة بهذه المهمة (0-10 معرفات)
  for (int typeCode = 0; typeCode < 10; typeCode++) {
    final id = NotificationHelper.getNotificationId(task.id, typeCode);
    await notificationService.cancelNotification(id);
  }
}
}