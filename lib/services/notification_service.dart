import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

    
  // تهيئة الإشعارات
    
  Future<bool> init() async {
    if (_isInitialized) return true;
    
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.local);

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);
      _isInitialized = true;
      print('  NotificationService initialized');
      return true;
      
    } catch (e) {
      print('❌ NotificationService init error: $e');
      return false;
    }
  }

    
  // عرض إشعار فوري
    
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) return false;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Notifications',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details);
      print('  Show notification: $id - $title');
      return true;
      
    } catch (e) {
      print('❌ Show notification error: $e');
      return false;
    }
  }

    
  // جدولة إشعار في وقت محدد
    
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) return false;
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      print('⚠️ Cannot schedule notification in the past: $scheduledDate');
      return false;
    }

    try {
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Notifications',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('  Scheduled notification: ID $id at $scheduledDate');
      return true;
      
    } catch (e) {
      print('❌ Schedule notification error: $e');
      return false;
    }
  }

    
  // إلغاء إشعار محدد
    
  Future<bool> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('  Cancelled notification: ID $id');
      return true;
    } catch (e) {
      print('❌ Cancel notification error: $e');
      return false;
    }
  }

    
  // إلغاء جميع الإشعارات
    
  Future<bool> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('  Cancelled all notifications');
      return true;
    } catch (e) {
      print('❌ Cancel all notifications error: $e');
      return false;
    }
  }
}