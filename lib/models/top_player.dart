import 'badge.dart';

class TopPlayer {
  final int id;
  final String name;
  final int rank;
  final double score;
  final int eventsCount;
  final double? averagePosition;
  final int top10Events;
  final int firstPlaceEvents;
  final DateTime? createdAt;
  final List<Badge> badges;

  TopPlayer({
    required this.id,
    required this.name,
    required this.rank,
    required this.score,
    required this.eventsCount,
    this.averagePosition,
    required this.top10Events,
    required this.firstPlaceEvents,
    this.createdAt,
    this.badges = const [],
  });

  factory TopPlayer.fromJson(Map<String, dynamic> json) {
    return TopPlayer(
      id: json['id'],
      name: json['name'],
      rank: json['rank'],
      score: (json['score'] as num).toDouble(),
      eventsCount: json['events_count'],
      averagePosition: json['average_position'] != null
          ? (json['average_position'] as num).toDouble()
          : null,
      top10Events: json['top_10_events'] ?? 0,
      firstPlaceEvents: json['first_place_events'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      badges: json['badges'] != null
          ? (json['badges'] as List)
              .map((badge) => Badge.fromJson(badge))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
      'score': score,
      'events_count': eventsCount,
      'average_position': averagePosition,
      'top_10_events': top10Events,
      'first_place_events': firstPlaceEvents,
      'created_at': createdAt?.toIso8601String(),
      'badges': badges.map((badge) => badge.toJson()).toList(),
    };
  }
}

class TopPlayersResponse {
  final List<TopPlayer> players;
  final String date;
  final String monthName;
  final int totalCount;

  TopPlayersResponse({
    required this.players,
    required this.date,
    required this.monthName,
    required this.totalCount,
  });

  factory TopPlayersResponse.fromJson(Map<String, dynamic> json) {
    return TopPlayersResponse(
      players: (json['players'] as List)
          .map((player) => TopPlayer.fromJson(player))
          .toList(),
      date: json['date'],
      monthName: json['month_name'],
      totalCount: json['total_count'],
    );
  }
}

class AvailableMonth {
  final String value;
  final String label;
  final int year;
  final int month;

  AvailableMonth({
    required this.value,
    required this.label,
    required this.year,
    required this.month,
  });

  factory AvailableMonth.fromJson(Map<String, dynamic> json) {
    return AvailableMonth(
      value: json['value'],
      label: json['label'],
      year: json['year'],
      month: json['month'],
    );
  }
}
