class TopPlayer {
  final int id;
  final String name;
  final String email;
  final int rank;
  final double score;
  final int eventsCount;
  final double? averagePosition;
  final DateTime? createdAt;

  TopPlayer({
    required this.id,
    required this.name,
    required this.email,
    required this.rank,
    required this.score,
    required this.eventsCount,
    this.averagePosition,
    this.createdAt,
  });

  factory TopPlayer.fromJson(Map<String, dynamic> json) {
    return TopPlayer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      rank: json['rank'],
      score: (json['score'] as num).toDouble(),
      eventsCount: json['events_count'],
      averagePosition: json['average_position'] != null
          ? (json['average_position'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rank': rank,
      'score': score,
      'events_count': eventsCount,
      'average_position': averagePosition,
      'created_at': createdAt?.toIso8601String(),
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
