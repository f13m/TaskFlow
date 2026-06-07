import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../../logic/task_provider.dart';
import '../../../../core/utils/priority_helper.dart';
import '../screens/edit_task_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskColor = PriorityHelper.getTaskColor(task.dueDate, task.isCompleted);
    final isOverdue = PriorityHelper.getTaskStatus(task.dueDate, task.isCompleted) == TaskStatus.overdue;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // سحب لليسار → حذف (نطلب تأكيد)
          return await _showDeleteConfirmationDialog(context);
        } else if (direction == DismissDirection.startToEnd) {
          // سحب لليمين → تعديل (بدون تأكيد)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: task),
            ),
          );
          return false; // لا نحذف البطاقة، فقط ننتقل للتعديل
        }
        return false;
      },
      //حساب الارتفاع الجوهري
      child: IntrinsicHeight(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(isDarkMode ? 0.2 : 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الشريط الجانبي الملون
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: taskColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              
              // المحتوى الرئيسي
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) {
                              context.read<TaskProvider>().toggleCompletion(task.id);
                            },
                            activeColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted 
                                      ? (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600)
                                      : (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
                                    size: 14,
                                    color: taskColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDueDate(task.dueDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: taskColor,
                                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (task.startTime != null || task.endTime != null)
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              task.formattedTimeRange,
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(width: 12),
                                  if (!task.isCompleted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(task.priority).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getPriorityText(task.priority),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _getPriorityColor(task.priority),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        //   زر الثلاث نقاط (محتفظ به)
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(context);
                            } else if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(task: task),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    if (isLeft) {
      // سحب لليمين ← تعديل (أزرق)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Edit',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    } else {
      // سحب لليسار ← حذف (أحمر)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white, size: 28),
          ],
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate == today) return 'Today';
    if (dueDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dueDate.isBefore(today)) return 'Overdue';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.green.shade400;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}