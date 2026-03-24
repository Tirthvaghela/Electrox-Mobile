class Election {
  final String id;
  final String title;
  final String description;
  final String organizerEmail;
  final String? organizationId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String resultVisibility;
  final List<Candidate> candidates;
  final List<Voter> voters;
  final int totalVotes;
  final bool? hasVoted;
  final DateTime createdAt;
  final DateTime? closedAt;

  Election({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerEmail,
    this.organizationId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.resultVisibility,
    required this.candidates,
    required this.voters,
    required this.totalVotes,
    this.hasVoted,
    required this.createdAt,
    this.closedAt,
  });

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizerEmail: json['organizer_email'] ?? '',
      organizationId: json['organization_id'],
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()).toLocal(),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()).toLocal(),
      status: json['status'] ?? 'draft',
      resultVisibility: json['result_visibility'] ?? 'hidden',
      candidates: (json['candidates'] as List<dynamic>? ?? [])
          .map((c) => Candidate.fromJson(c))
          .toList(),
      voters: (json['voters'] as List<dynamic>? ?? [])
          .map((v) => Voter.fromJson(v))
          .toList(),
      totalVotes: json['total_votes'] ?? 0,
      hasVoted: json['has_voted'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'organizer_email': organizerEmail,
      'organization_id': organizationId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'result_visibility': resultVisibility,
      'candidates': candidates.map((c) => c.toJson()).toList(),
      'voters': voters.map((v) => v.toJson()).toList(),
      'total_votes': totalVotes,
      'has_voted': hasVoted,
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }

  bool get isDraft => status == 'draft';
  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'active':
        return 'Active';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  bool get canVote => isActive && DateTime.now().isBefore(endDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);
  
  double get turnoutPercentage => voters.isNotEmpty ? (totalVotes / voters.length) * 100 : 0;
  int get remainingVoters => voters.length - totalVotes;
  
  // Add votes property for compatibility
  List<Vote> get votes => []; // This would be populated from API
}

class Vote {
  final String voterEmail;
  final String candidateEmail;
  final DateTime votedAt;

  Vote({
    required this.voterEmail,
    required this.candidateEmail,
    required this.votedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      voterEmail: json['voter_email'] ?? '',
      candidateEmail: json['candidate_email'] ?? '',
      votedAt: DateTime.parse(json['voted_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voter_email': voterEmail,
      'candidate_email': candidateEmail,
      'voted_at': votedAt.toIso8601String(),
    };
  }
}

class ElectionResults {
  final int totalVotes;
  final int totalVoters;
  final double turnoutPercentage;
  final List<CandidateResult> results;
  final CandidateResult? winner;
  final bool visible;

  ElectionResults({
    required this.totalVotes,
    required this.totalVoters,
    required this.turnoutPercentage,
    required this.results,
    this.winner,
    this.visible = true,
  });

  factory ElectionResults.fromJson(Map<String, dynamic> json) {
    final visible = json['visible'] ?? true;
    final rawResults = visible
        ? (json['results'] as List<dynamic>? ?? [])
        : <dynamic>[];
    final resultsList = rawResults
        .map((r) => CandidateResult.fromJson(r))
        .toList();
    
    // Sort by votes descending
    resultsList.sort((a, b) => b.votes.compareTo(a.votes));

    final totalVoters = json['total_voters'] ?? 0;
    final totalVotes = json['total_votes'] ?? 0;
    
    return ElectionResults(
      totalVotes: totalVotes,
      totalVoters: totalVoters,
      turnoutPercentage: totalVoters > 0
          ? (totalVotes / totalVoters * 100).toDouble()
          : (json['turnout_percentage'] ?? 0.0).toDouble(),
      results: resultsList,
      winner: resultsList.isNotEmpty ? resultsList.first : null,
      visible: visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_votes': totalVotes,
      'total_voters': totalVoters,
      'turnout_percentage': turnoutPercentage,
      'results': results.map((r) => r.toJson()).toList(),
      'winner': winner?.toJson(),
    };
  }
}

class CandidateResult {
  final String name;
  final String email;
  final int votes;

  CandidateResult({
    required this.name,
    required this.email,
    required this.votes,
  });

  factory CandidateResult.fromJson(Map<String, dynamic> json) {
    return CandidateResult(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'votes': votes,
    };
  }

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }
}

class Candidate {
  final String name;
  final String email;
  final String? bio;
  final String? photo;
  final int? votes;

  Candidate({
    required this.name,
    required this.email,
    this.bio,
    this.photo,
    this.votes,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
      photo: json['photo'],
      votes: json['votes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'photo': photo,
      'votes': votes,
    };
  }
}

class Voter {
  final String name;
  final String email;
  final bool? hasVoted;
  final DateTime? votedAt;

  Voter({
    required this.name,
    required this.email,
    this.hasVoted,
    this.votedAt,
  });

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      hasVoted: json['has_voted'],
      votedAt: json['voted_at'] != null ? DateTime.parse(json['voted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'has_voted': hasVoted,
      'voted_at': votedAt?.toIso8601String(),
    };
  }
}