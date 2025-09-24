import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: Key(todo.id.toString()),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Düzenle',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Sil',
            ),
          ],
        ),
        child: Card(
          elevation: todo.isCompleted ? 1 : 2,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Completion Checkbox
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: todo.isCompleted
                                ? Colors.green
                                : Color(todo.priority.colorValue),
                            width: 2,
                          ),
                          color: todo.isCompleted
                              ? Colors.green
                              : Colors.transparent,
                        ),
                        child: todo.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Title and Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      todo.priority.colorValue,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    todo.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(todo.priority.colorValue),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      todo.priority.colorValue,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    todo.priority.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(todo.priority.colorValue),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Overdue indicator
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),

                  // Description
                  if (todo.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      todo.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: todo.isCompleted
                            ? Colors.grey
                            : Colors.grey[600],
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Due Date
                  if (todo.dueDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(todo.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDateDay == today) {
      return 'Bugün ${DateFormat('HH:mm').format(dueDate)}';
    } else if (dueDateDay == tomorrow) {
      return 'Yarın ${DateFormat('HH:mm').format(dueDate)}';
    } else if (dueDateDay.isBefore(today)) {
      final difference = today.difference(dueDateDay).inDays;
      return '$difference gün gecikti';
    } else {
      return DateFormat('dd MMM yyyy HH:mm').format(dueDate);
    }
  }
}
