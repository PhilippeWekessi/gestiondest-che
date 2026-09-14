import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.ink),
            onPressed: () async {
              final updatedTask = await Navigator.push<Task>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(existingTask: task),
                ),
              );
              if (updatedTask != null && context.mounted) {
                Navigator.pop(context, updatedTask);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: task.priority.backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Priorité ${task.priority.label.toLowerCase()}',
                style: TextStyle(
                  color: task.priority.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${task.dateTime.day}/${task.dateTime.month}/${task.dateTime.year} · '
              '${task.dateTime.hour.toString().padLeft(2, '0')}:${task.dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkSoft,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              task.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF3A3F52),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Partagé sur les réseaux sociaux (démo)',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.line),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Partager',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 'deleted'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.high,
                        backgroundColor: AppColors.highBg,
                        side: const BorderSide(color: AppColors.high),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}