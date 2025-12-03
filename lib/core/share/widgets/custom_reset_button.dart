import 'package:flutter/material.dart';

class CustomResetButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;

  const CustomResetButton({
    super.key,
    required this.onTap,
    this.tooltip = 'إعادة تعيين العدادات',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary.withOpacity(0.18), primary.withOpacity(0.28)],
              ),
              border: Border.all(color: primary.withOpacity(0.40), width: 1),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.restart_alt_rounded,
              color: primary,
              size: 22,
              semanticLabel: tooltip,
            ),
          ),
        ),
      ),
    );
  }
}
