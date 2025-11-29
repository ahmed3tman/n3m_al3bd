import 'package:flutter/material.dart';
import '../../data/models/daily_task_model.dart';

class TaskItemWidget extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onToggle;

  const TaskItemWidget({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = task.isLocked;
    final isCompleted = task.isCompleted;
    final isWird = !task.isPrayer;

    // Determine styles based on state
    Color backgroundColor;
    Gradient? backgroundGradient;
    Border? border;
    List<BoxShadow> shadows = [];

    if (isDisabled) {
      // Locked State
      backgroundColor = theme.cardColor.withOpacity(0.5);
      border = Border.all(color: theme.dividerColor.withOpacity(0.2));
    } else if (isCompleted) {
      // Completed State
      backgroundColor = theme.cardColor.withOpacity(0.9);
      border = Border.all(
        color: theme.colorScheme.primary.withOpacity(0.3),
        width: 1,
      );
      shadows = [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      // Pending State
      backgroundColor = theme.colorScheme.error.withOpacity(0.15);
      border = Border.all(
        color: theme.colorScheme.error.withOpacity(0.6),
        width: 1,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: border,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Task Content (Right side in RTL)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.nameAr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isCompleted
                                ? FontWeight.normal
                                : FontWeight.w600,
                            color: isDisabled
                                ? theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.4)
                                : isCompleted
                                ? theme.colorScheme.primary.withOpacity(0.8)
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        if (task.isPrayer && task.unlockTime != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: isDisabled
                                      ? theme.disabledColor
                                      : theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTime(task.unlockTime!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDisabled
                                        ? theme.disabledColor
                                        : theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isWird)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              task.wirdAmount > 0
                                  ? '${task.wirdAmount} صفحة'
                                  : 'اضغط لتسجيل الورد',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: task.wirdAmount > 0
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Status Indicator (Left side in RTL)
                  if (isWird)
                    _buildWirdAction(theme, task)
                  else
                    _buildPrayerStatusBadge(theme, isDisabled, isCompleted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerStatusBadge(
    ThemeData theme,
    bool isDisabled,
    bool isCompleted,
  ) {
    String text;
    Color color;
    Color backgroundColor;
    IconData? icon;

    if (isDisabled) {
      text = 'لم يؤذن بعد';
      color = theme.disabledColor;
      backgroundColor = theme.disabledColor.withOpacity(0.1);
      icon = Icons.lock_outline_rounded;
    } else if (isCompleted) {
      text = 'تم بحمد الله';
      color = Colors.white;
      backgroundColor = theme.colorScheme.primary;
      icon = Icons.check_circle_rounded;
    } else {
      text = 'صلاة لم تصليها';
      color = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.error.withOpacity(0.1);
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: Colors.white, width: 1.5)
            : Border.all(color: color.withOpacity(0.2)),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWirdAction(ThemeData theme, DailyTask task) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.edit_note_rounded,
        color: theme.colorScheme.primary,
        size: 20,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }
}
