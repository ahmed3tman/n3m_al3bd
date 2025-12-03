import 'package:flutter/material.dart';

class CustomEdgeButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool isLeading;
  final double width;
  final double height;

  const CustomEdgeButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.isLeading = true,
    this.width = 80,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = isLeading
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    final border = isLeading
        ? Border(
            top: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
            bottom: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
          )
        : Border(
            top: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
            bottom: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            right: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: borderRadius,
          border: border,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Icon(icon, size: 28, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
