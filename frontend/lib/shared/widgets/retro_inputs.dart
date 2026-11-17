import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'retro_buttons.dart';

class RetroTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;

  const RetroTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: RetroColors.textPrimary)),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          autofocus: autofocus,
          style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: RetroColors.borderDark, width: 1)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: RetroColors.border, width: 1)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: RetroColors.borderBlue, width: 2)),
          ),
        ),
      ],
    );
  }
}

class RetroLoading extends StatelessWidget {
  final String message;
  const RetroLoading({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: RetroColors.headerBg)),
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class RetroError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const RetroError(this.message, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFEEEE), border: Border.all(color: RetroColors.accent, width: 1)),
      child: Row(
        children: [
          const Text('⚠ ', style: TextStyle(color: RetroColors.accent, fontSize: 14)),
          Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.accent))),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            RetroButton(label: 'Retry', onPressed: onRetry, isSmall: true),
          ],
        ],
      ),
    );
  }
}
