class AuditLog {
  final String id;
  final String userEmail;
  final String action;
  final String? resource;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userEmail,
    required this.action,
    this.resource,
    required this.details,
    this.ipAddress,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['_id'] ?? json['id'] ?? '',
      userEmail: json['user_email'] ?? '',
      action: json['action'] ?? '',
      resource: json['resource'],
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      ipAddress: json['ip_address'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_email': userEmail,
      'action': action,
      'resource': resource,
      'details': details,
      'ip_address': ipAddress,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get formattedAction {
    return action
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'AuditLog(id: $id, userEmail: $userEmail, action: $action, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}