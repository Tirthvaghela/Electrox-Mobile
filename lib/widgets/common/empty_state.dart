import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? subtitle; // For backward compatibility
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.subtitle,
    this.action,
  });

  // Constructor for backward compatibility with subtitle
  const EmptyState.withSubtitle({
    super.key,
    required this.icon,
    required this.title,
    required String subtitle,
    this.action,
  }) : message = subtitle, subtitle = subtitle;

  @override
  Widget build(BuildContext context) {
    final displayMessage = subtitle ?? message;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              displayMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}