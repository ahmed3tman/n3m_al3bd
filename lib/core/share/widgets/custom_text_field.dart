import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final TextDirection? textDirection;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textDirection: textDirection,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400, // Regular weight
        color: onSurfaceColor,
        fontFamily: 'GeneralFont',
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: primaryColor.withOpacity(0.8),
          fontWeight: FontWeight.w400,
          fontFamily: 'GeneralFont',
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          color: onSurfaceColor.withOpacity(0.4),
          fontWeight: FontWeight.w300, // Light weight
          fontFamily: 'GeneralFont',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        prefixIcon: prefixIcon,
      ),
    );
  }
}
