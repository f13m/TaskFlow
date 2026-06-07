import 'package:flutter/material.dart';

class AppColors {
  // ألوان المهام حسب الأولوية (حسب اقتراحك)
  static const Color overdue = Colors.grey;        // رمادي: فات موعدها
  static const Color dueToday = Colors.red;        // أحمر: مهام اليوم
  static const Color dueTomorrow = Colors.orange;  // برتقالي: مهام غداً
  static const Color upcoming = Colors.green;      // أخضر: مهام المستقبل
  
  // لون المهمة المكتملة
  static const Color completed = Colors.grey;
  
  // ألوان إضافية
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Colors.redAccent;
}