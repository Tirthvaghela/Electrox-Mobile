import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return _buildSecondaryButton();
    } else {
      return _buildPrimaryButton();
    }
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentOrange,
          foregroundColor: AppTheme.primaryBlack,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: 14,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          textStyle: AppTheme.titleMedium,
          disabledBackgroundColor: AppTheme.accentOrange.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlack),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryNavy,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppTheme.primaryNavy, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          textStyle: AppTheme.titleMedium,
          disabledForegroundColor: AppTheme.primaryNavy.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}