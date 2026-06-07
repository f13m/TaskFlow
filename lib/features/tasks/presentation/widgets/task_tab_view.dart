import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import 'task_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/priority_helper.dart';  //   تمت الإضافة: لاستيراد دالة الترتيب

class TaskTabView extends StatelessWidget {
  final List<TaskModel> tasks;
  
  const TaskTabView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
      
    //    تم التعديل: ترتيب المهام حسب الأولوية قبل عرضها
      
    final sortedTasks = PriorityHelper.sortTasksByPriority(tasks);
    
    if (sortedTasks.isEmpty) {
      return const EmptyState(
        message: 'No tasks here',
        icon: Icons.check_circle_outline,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: sortedTasks[index]);
      },
    );
  }
}