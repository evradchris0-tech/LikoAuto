import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liko_auto/core/theme/app_radius.dart';

class LikoTextField extends StatelessWidget {
  const LikoTextField({
    required this.hintText,
    super.key,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.validator,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.label,
  });

  final String hintText;
  final String? label;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      validator: validator,
      autofocus: autofocus,
      readOnly: readOnly,
      onTap: onTap,
      style: tt.bodyLarge?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(borderRadius: AppRadius.rButton),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
      ),
    );
  }
}
