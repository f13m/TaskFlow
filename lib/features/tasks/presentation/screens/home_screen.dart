import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../../logic/task_provider.dart';
import '../../../../core/utils/priority_helper.dart';
import '../widgets/task_tab_view.dart';
import '../../../../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.request();
  if (status.isGranted) {
    print(' Notification permission granted');
  } else {
    print(' Notification permission denied');
  }
}

 @override
void initState() {
  super.initState();
  _tabController = TabController(length: 4, vsync: this);
  _requestNotificationPermission(); 
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
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
            child: TabBar(
              controller: _tabController,
              isScrollable: false,  //  غير قابل للتمرير
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              //  تقسيم متساوٍ لعرض التبويبات
              tabAlignment: TabAlignment.fill,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Today', icon: Icon(Icons.today, size: 20)),
                Tab(text: 'Tomorrow', icon: Icon(Icons.calendar_today, size: 20)),
                Tab(text: 'Upcoming', icon: Icon(Icons.calendar_month, size: 20)),
                Tab(text: 'Overdue', icon: Icon(Icons.warning_amber, size: 20)),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              TaskTabView(tasks: taskProvider.getTasksByStatus(TaskStatus.dueToday)),
              TaskTabView(tasks: taskProvider.getTasksByStatus(TaskStatus.dueTomorrow)),
              TaskTabView(tasks: taskProvider.getTasksByStatus(TaskStatus.upcoming)),
              TaskTabView(tasks: taskProvider.getTasksByStatus(TaskStatus.overdue)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) {
        String selectedPriority = 'medium';
        DateTime? _startTime;
        DateTime? _endTime;
        
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            //  دوال اختيار الوقت (داخل الـ builder)
            Future<void> _selectStartTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                final now = DateTime.now();
                _startTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                setStateDialog(() {});
              }
            }

            Future<void> _selectEndTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                final now = DateTime.now();
                _endTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                setStateDialog(() {});
              }
            }
            
            return AlertDialog(
              title: const Text('Add New Task'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // حقل عنوان المهمة
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // تاريخ الاستحقاق
                    ListTile(
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: const Text('Due Date'),
                      trailing: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    //  وقت البدء (جديد)
                    ListTile(
                      leading: const Icon(Icons.play_arrow_rounded),
                      title: const Text('Start Time'),
                      trailing: Text(
                        _startTime != null 
                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                            : 'Not set',
                      ),
                      onTap: _selectStartTime,
                    ),
                    
                    //   وقت الانتهاء (جديد)
                    ListTile(
                      leading: const Icon(Icons.stop_rounded),
                      title: const Text('End Time'),
                      trailing: Text(
                        _endTime != null 
                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                            : 'Not set',
                      ),
                      onTap: _selectEndTime,
                    ),
                    const SizedBox(height: 8),
                    
                    // الأولوية
                    ListTile(
                      leading: const Icon(Icons.priority_high),
                      title: const Text('Priority'),
                      trailing: DropdownButton<String>(
                        value: selectedPriority,
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'high', child: Text('High')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() {
                              selectedPriority = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      TaskPriority priority;
                      switch (selectedPriority) {
                        case 'high':
                          priority = TaskPriority.high;
                          break;
                        case 'low':
                          priority = TaskPriority.low;
                          break;
                        default:
                          priority = TaskPriority.medium;
                      }
                      
                      final newTask = TaskModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: null,
                        dueDate: selectedDate,
                        priority: priority,
                        createdAt: DateTime.now(),
                        startTime: _startTime,   //   إضافة وقت البدء
                        endTime: _endTime,       //   إضافة وقت الانتهاء
                      );
                      
                      context.read<TaskProvider>().addTask(newTask);
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task added successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}