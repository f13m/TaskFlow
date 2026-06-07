import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../tasks/logic/task_provider.dart';
import '../../../tasks/data/models/task_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
    
  // المتغيرات الأساسية
    
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;
  late List<DateTime> _currentWeekDays;
  late DateTime _selectedDay;
  double _weeklyCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCurrentWeek();
  }

    
  // دوال تهيئة الأسبوع
    
  void _initializeCurrentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // الأسبوع يبدأ من اليوم الحالي
    _startOfWeek = today;
    _endOfWeek = today.add(const Duration(days: 6));
    _currentWeekDays = _getWeekDays(_startOfWeek);
    _selectedDay = today;
  }

  List<DateTime> _getWeekDays(DateTime start) {
    return List.generate(7, (index) {
      return DateTime(start.year, start.month, start.day).add(Duration(days: index));
    });
  }

    
  // دوال حساب النسب
    
  double _getCompletionRateForDay(DateTime day, List<TaskModel> tasks) {
    final tasksDueThatDay = tasks.where((task) {
      final dueDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return dueDate == day;
    }).toList();
    
    if (tasksDueThatDay.isEmpty) return 0.0;
    
    final completedCount = tasksDueThatDay.where((task) => task.isCompleted).length;
    return completedCount / tasksDueThatDay.length;
  }

  double _getWeeklyCompletionRate(List<DateTime> weekDays, List<TaskModel> tasks) {
    if (weekDays.isEmpty) return 0.0;
    
    double totalRate = 0.0;
    for (final day in weekDays) {
      totalRate += _getCompletionRateForDay(day, tasks);
    }
    return totalRate / weekDays.length;
  }

    
  // دوال التنسيق والعرض
    
  String _getDayTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${date.day}/${date.month}';
  }

  String _getShortDayName(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _getMotivationalMessage(int percent) {
    if (percent >= 80) return 'Excellent! You\'re crushing your goals! 🔥';
    if (percent >= 60) return 'Great job! Keep up the momentum! 💪';
    if (percent >= 40) return 'Good progress! You\'re on the right track! 📈';
    if (percent >= 20) return 'Keep going! Every task counts! 🌱';
    return 'Start with small tasks to build momentum! ✨';
  }

    
  // واجهة المستخدم الرئيسية
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final allTasks = taskProvider.tasks;
          
          // تحديث نسبة الإنجاز الأسبوعية
          _weeklyCompletionRate = _getWeeklyCompletionRate(_currentWeekDays, allTasks);
          
          // بيانات اليوم المختار
          final selectedRate = _getCompletionRateForDay(_selectedDay, allTasks);
          final selectedPercent = (selectedRate * 100).toInt();
          final tasksOnSelectedDay = allTasks.where((task) {
            final dueDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
            return dueDate == _selectedDay;
          }).toList();
          final completedOnSelectedDay = tasksOnSelectedDay.where((t) => t.isCompleted).length;
          
          // التحقق من وجود أي مهام في الأسبوع
          final hasTasksInWeek = _currentWeekDays.any((day) {
            return allTasks.any((task) {
              final dueDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
              return dueDate == day;
            });
          });

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                  
                // الدائرتان (الكبيرة والصغيرة)
                  
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // الدائرة الكبيرة
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 190,
                            height: 190,
                            child: CircularProgressIndicator(
                              value: selectedRate,
                              strokeWidth: 12,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$selectedPercent%',
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${completedOnSelectedDay}/${tasksOnSelectedDay.length} tasks',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getDayTitle(_selectedDay),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // الدائرة الصغيرة (نسبة الأسبوع)
                    Positioned(
                      top: 0,
                      left: 10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                value: _weeklyCompletionRate,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              '${(_weeklyCompletionRate * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                  
                // التنقل بين الأسابيع
                  
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الأسبوع السابق
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
                            _endOfWeek = _endOfWeek.subtract(const Duration(days: 7));
                            _currentWeekDays = _getWeekDays(_startOfWeek);
                            if (!_currentWeekDays.contains(_selectedDay)) {
                              _selectedDay = _currentWeekDays.first;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                      
                      Column(
                        children: [
                          Text(
                            '${_startOfWeek.day}/${_startOfWeek.month}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            'to ${_endOfWeek.day}/${_endOfWeek.month}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      // زر الأسبوع التالي
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _startOfWeek = _startOfWeek.add(const Duration(days: 7));
                            _endOfWeek = _endOfWeek.add(const Duration(days: 7));
                            _currentWeekDays = _getWeekDays(_startOfWeek);
                            if (!_currentWeekDays.contains(_selectedDay)) {
                              _selectedDay = _currentWeekDays.first;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                  
                // الرسم البياني
                  
                if (hasTasksInWeek)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 280,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 1.0,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _currentWeekDays.length) {
                                    final day = _currentWeekDays[index];
                                    final isToday = day == DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            _getShortDayName(day),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                              color: isToday 
                                                  ? Theme.of(context).colorScheme.primary 
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                          if (isToday)
                                            Container(
                                              width: 5,
                                              height: 5,
                                              margin: const EdgeInsets.only(top: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 50,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      '${(value * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 45,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 0.25,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 0.5,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                           // handleTouches: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final day = _currentWeekDays[group.x.toInt()];
                                final rate = _getCompletionRateForDay(day, allTasks);
                                return BarTooltipItem(
                                  '${(rate * 100).toInt()}%\n${_getDayTitle(day)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
                                final index = barTouchResponse.spot!.touchedBarGroupIndex;
                                if (index >= 0 && index < _currentWeekDays.length) {
                                  setState(() {
                                    _selectedDay = _currentWeekDays[index];
                                  });
                                }
                              }
                            },
                          ),
                          barGroups: List.generate(_currentWeekDays.length, (index) {
                            final day = _currentWeekDays[index];
                            final rate = _getCompletionRateForDay(day, allTasks);
                            final isSelected = day == _selectedDay;
                            final hasTasks = allTasks.any((task) {
                              final dueDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
                              return dueDate == day;
                            });
                            
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: rate,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.blue.shade400
                                          : Colors.blue.shade300),
                                  width: hasTasks ? 36 : 20,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                              showingTooltipIndicators: isSelected ? [0] : [],
                            );
                          }),
                        ),
                      ),
                    ),
                  )
                else
                  // رسالة عند عدم وجود مهام في الأسبوع
                  Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks this week',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add tasks to see your progress',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                  
                // الرسالة التحفيزية
                  
                if (hasTasksInWeek)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Keep Going!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getMotivationalMessage(selectedPercent),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}