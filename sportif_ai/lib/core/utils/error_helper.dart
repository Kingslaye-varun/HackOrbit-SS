import 'package:flutter/material.dart';

/// A utility class to handle error styling and display based on error types
class ErrorHelper {
  /// Get the appropriate background color for error messages based on error type
  static Color getErrorBackgroundColor(String? errorType) {
    switch (errorType) {
      case 'auth':
        return Colors.orange.shade50;
      case 'network':
        return Colors.blue.shade50;
      case 'database':
        return Colors.purple.shade50;
      case 'unknown':
      default:
        return Colors.red.shade50;
    }
  }

  /// Get the appropriate border color for error messages based on error type
  static Color getErrorBorderColor(String? errorType) {
    switch (errorType) {
      case 'auth':
        return Colors.orange.shade300;
      case 'network':
        return Colors.blue.shade300;
      case 'database':
        return Colors.purple.shade300;
      case 'unknown':
      default:
        return Colors.red.shade300;
    }
  }

  /// Get the appropriate text color for error messages based on error type
  static Color getErrorTextColor(String? errorType) {
    switch (errorType) {
      case 'auth':
        return Colors.orange.shade800;
      case 'network':
        return Colors.blue.shade800;
      case 'database':
        return Colors.purple.shade800;
      case 'unknown':
      default:
        return Colors.red.shade800;
    }
  }

  /// Get the appropriate icon for error messages based on error type
  static IconData getErrorIcon(String? errorType) {
    switch (errorType) {
      case 'auth':
        return Icons.person_off_outlined;
      case 'network':
        return Icons.wifi_off_outlined;
      case 'database':
        return Icons.storage_outlined;
      case 'unknown':
      default:
        return Icons.error_outline;
    }
  }

  /// Build an error message container with appropriate styling
  static Widget buildErrorWidget(String? errorMessage, String? errorType) {
    if (errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getErrorBackgroundColor(errorType),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getErrorBorderColor(errorType),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            getErrorIcon(errorType),
            color: getErrorTextColor(errorType),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: getErrorTextColor(errorType),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}