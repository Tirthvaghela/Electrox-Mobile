import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLines;
  final String? helperText;
  final bool required;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.helperText,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: RichText(
            text: TextSpan(
              text: label,
              style: AppTheme.labelMedium,
              children: [
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Text Field
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            helperText: helperText,
            helperStyle: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: enabled ? AppTheme.cardColor : AppTheme.backgroundGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.textHint),
            ),
            contentPadding: const EdgeInsets.all(AppTheme.paddingInput),
            hintStyle: const TextStyle(
              color: AppTheme.textHint,
              fontFamily: 'Roboto',
            ),
            errorStyle: const TextStyle(
              color: AppTheme.errorRed,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }
}