import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../../logic/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  
  //     متغيرات وقت البدء والانتهاء
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.dueDate;
    
    //    تعبئة وقت البدء والانتهاء من المهمة الحالية
    _startTime = widget.task.startTime;
    _endTime = widget.task.endTime;
    
    switch (widget.task.priority) {
      case TaskPriority.high:
        _selectedPriority = 'high';
        break;
      case TaskPriority.medium:
        _selectedPriority = 'medium';
        break;
      case TaskPriority.low:
        _selectedPriority = 'low';
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // حقل عنوان المهمة
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),

            // اختيار التاريخ
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              trailing: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            
            // وقت البدء (Start Time)
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Start Time'),
              trailing: Text(
                _startTime != null 
                    ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not set',
              ),
              onTap: () => _selectStartTime(),
            ),
            
            //   وقت الانتهاء (End Time)
            ListTile(
              leading: const Icon(Icons.stop_rounded),
              title: const Text('End Time'),
              trailing: Text(
                _endTime != null 
                    ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not set',
              ),
              onTap: () => _selectEndTime(),
            ),
            const SizedBox(height: 8),

            // اختيار الأولوية
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Priority'),
              trailing: DropdownButton<String>(
                value: _selectedPriority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 30),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //    دالة اختيار وقت البدء
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _startTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  //   دالة اختيار وقت الانتهاء
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _endTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    TaskPriority priority;
    switch (_selectedPriority) {
      case 'high':
        priority = TaskPriority.high;
        break;
      case 'low':
        priority = TaskPriority.low;
        break;
      default:
        priority = TaskPriority.medium;
    }

    //   تضمين وقت البدء والانتهاء في التحديث
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      dueDate: _selectedDate,
      priority: priority,
      startTime: _startTime,
      endTime: _endTime,
    );

    context.read<TaskProvider>().updateTask(updatedTask);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully!')),
    );
  }
}