import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusCard)),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingCard),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  value,
                  style: AppTheme.displayLarge.copyWith(color: color),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.paddingCard),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: card,
        ),
      );
    }

    return card;
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Widget? child;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.spacingS),
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium),
                    const SizedBox(height: AppTheme.spacingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: AppTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                      child: Text(
                        status,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textOnDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            child!,
          ],
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.trailing,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryNavy;
    
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.spacingS),
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        subtitle!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            child!,
          ],
        ],
      ),
    );
  }
}