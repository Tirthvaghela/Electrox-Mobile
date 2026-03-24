class Organization {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrganizationStats? stats;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'active',
      createdBy: json['created_by'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      stats: json['stats'] != null ? OrganizationStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'stats': stats?.toJson(),
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrganizationStats? stats,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Organization && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class OrganizationStats {
  final int users;
  final int elections;
  final int votes;

  OrganizationStats({
    required this.users,
    required this.elections,
    required this.votes,
  });

  factory OrganizationStats.fromJson(Map<String, dynamic> json) {
    return OrganizationStats(
      users: json['users'] ?? 0,
      elections: json['elections'] ?? 0,
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'elections': elections,
      'votes': votes,
    };
  }

  @override
  String toString() {
    return 'OrganizationStats(users: $users, elections: $elections, votes: $votes)';
  }
}