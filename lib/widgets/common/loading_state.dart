import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? message; // Alias for subtitle for backward compatibility
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.message,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final displaySubtitle = subtitle ?? message;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingScreen),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (displaySubtitle != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                displaySubtitle,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}