class UserEvent {
  final int id;
  final String name;
  final String status;
  final int? startedAt;
  final int? stoppedAt;
  final DateTime? startsAt;
  final DateTime createdAt;
  final EventParticipation participation;

  UserEvent({
    required this.id,
    required this.name,
    required this.status,
    this.startedAt,
    this.stoppedAt,
    this.startsAt,
    required this.createdAt,
    required this.participation,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    return UserEvent(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      startedAt: json['started_at'],
      stoppedAt: json['stopped_at'],
      startsAt:
          json['starts_at'] != null ? DateTime.parse(json['starts_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      participation: EventParticipation.fromJson(json['participation']),
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'started':
        return 'In Progress';
      case 'paused':
        return 'Paused';
      case 'upcoming':
        return 'Upcoming';
      default:
        return status;
    }
  }

  String get participationStatusDisplay {
    switch (participation.status.toLowerCase()) {
      case 'playing':
        return 'Active';
      case 'dropped':
        return 'Eliminated';
      default:
        return participation.status;
    }
  }
}

class EventParticipation {
  final int id;
  final String status;
  final int? position;
  final int? finalTablePosition;
  final double score;
  final double balance;
  final DateTime joinedAt;

  EventParticipation({
    required this.id,
    required this.status,
    this.position,
    this.finalTablePosition,
    required this.score,
    required this.balance,
    required this.joinedAt,
  });

  factory EventParticipation.fromJson(Map<String, dynamic> json) {
    return EventParticipation(
      id: json['id'],
      status: json['status'],
      position: json['position'],
      finalTablePosition: json['final_table_position'],
      score: (json['score'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}

class UserEventsResponse {
  final List<UserEvent> events;
  final int totalEvents;

  UserEventsResponse({
    required this.events,
    required this.totalEvents,
  });

  factory UserEventsResponse.fromJson(Map<String, dynamic> json) {
    return UserEventsResponse(
      events: (json['events'] as List)
          .map((event) => UserEvent.fromJson(event))
          .toList(),
      totalEvents: json['total_events'],
    );
  }
}
