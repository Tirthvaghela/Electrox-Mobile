import 'package:flutter/material.dart';

class ErrorHandler {
  static String handleApiError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  static void logError(String message, [dynamic error]) {
    debugPrint('Error: $message');
    if (error != null) {
      debugPrint('Details: $error');
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor != null ? Colors.white : null,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}