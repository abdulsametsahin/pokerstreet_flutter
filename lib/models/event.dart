class Event {
  final int id;
  final String name;
  final String description;
  final String status;
  final DateTime startsAt;
  final int? startedAt;
  final int timeElapsed;
  final bool isPublic;
  final bool trackRanking;
  final bool displayPrizePool;
  final int totalMinutes;
  final int remaining;
  final int elapsedTime;
  final int activePlayersCount;
  final int playersCount;
  final List<Level> levels;
  final List<Participant> participants;
  final List<Prize> prizes;
  final Level? currentLevel;
  final Level? nextLevel;
  final int levelRemaining;
  final AppBuyIn? appBuyIn;
  final List<AppPrize> appPrizes;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startsAt,
    this.startedAt,
    required this.timeElapsed,
    required this.isPublic,
    required this.trackRanking,
    required this.displayPrizePool,
    required this.totalMinutes,
    required this.remaining,
    required this.elapsedTime,
    required this.activePlayersCount,
    required this.playersCount,
    required this.levels,
    required this.participants,
    required this.prizes,
    this.currentLevel,
    this.nextLevel,
    required this.levelRemaining,
    this.appBuyIn,
    required this.appPrizes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse app buy-in data
    AppBuyIn? appBuyIn;
    if (json['app_buyin'] != null && json['app_buyin'] is Map) {
      final buyInData = json['app_buyin'] as Map<String, dynamic>;
      if (buyInData['rows'] != null &&
          buyInData['rows'] is List &&
          (buyInData['rows'] as List).isNotEmpty) {
        final firstRow = (buyInData['rows'] as List).first;
        appBuyIn = AppBuyIn(
          action: firstRow['action'] ?? '',
          price: firstRow['price'] ?? '',
          chips: firstRow['chips'] ?? '',
          totalPrizepool: buyInData['total_prizepool'] ?? '',
        );
      }
    }

    // Parse app prizes data
    List<AppPrize> appPrizes = [];
    if (json['app_prizes'] != null && json['app_prizes'] is List) {
      appPrizes = (json['app_prizes'] as List)
          .map((prize) => AppPrize.fromJson(prize))
          .toList();
    }

    return Event(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'upcoming',
      startsAt: DateTime.parse(json['starts_at']),
      startedAt: json['started_at'],
      timeElapsed: json['time_elapsed'] ?? 0,
      isPublic: json['is_public'] ?? false,
      trackRanking: json['track_ranking'] ?? false,
      displayPrizePool: json['display_prize_pool'] ?? false,
      totalMinutes: _parseInt(json['total_minutes']),
      remaining: json['remaining'] ?? 0,
      elapsedTime: _parseDouble(json['elapsed_time']).toInt(),
      activePlayersCount: json['active_players_count'] ?? 0,
      playersCount: json['players_count'] ?? 0,
      levels: (json['levels'] as List?)
              ?.map((level) => Level.fromJson(level))
              .toList() ??
          [],
      participants: (json['participants'] as List?)
              ?.map((participant) => Participant.fromJson(participant))
              .toList() ??
          [],
      prizes: (json['prizes'] as List?)
              ?.map((prize) => Prize.fromJson(prize))
              .toList() ??
          [],
      currentLevel: json['current_level'] != null
          ? Level.fromJson(json['current_level'])
          : null,
      nextLevel: json['next_level'] != null
          ? Level.fromJson(json['next_level'])
          : null,
      levelRemaining: _parseDouble(json['level_remaining']).toInt(),
      appBuyIn: appBuyIn,
      appPrizes: appPrizes,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool get isRunning => status == 'running';
  bool get isUpcoming => status == 'upcoming' || status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isPaused => status == 'paused';

  String get statusColor {
    switch (status) {
      case 'running':
        return 'green';
      case 'paused':
        return 'yellow';
      case 'completed':
        return 'red';
      default:
        return 'indigo';
    }
  }

  Duration get remainingDuration => Duration(milliseconds: remaining);
  Duration get levelRemainingDuration => Duration(milliseconds: levelRemaining);
}

class Level {
  final int id;
  final int? levelNumber;
  final int? smallBlind;
  final int? bigBlind;
  final int? ante;
  final int duration;
  final String type;

  Level({
    required this.id,
    this.levelNumber,
    this.smallBlind,
    this.bigBlind,
    this.ante,
    required this.duration,
    required this.type,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      levelNumber: json['level_number'],
      smallBlind: json['small_blind'],
      bigBlind: json['big_blind'],
      ante: json['ante'],
      duration: json['duration'] ?? 0,
      type: json['type'] ?? 'round',
    );
  }

  bool get isBreak => type == 'break';
  bool get isRound => type == 'round';

  String get blindsText {
    if (isBreak) return 'Break';
    if (ante != null && ante! > 0) {
      return '$smallBlind/$bigBlind ($ante)';
    }
    return '$smallBlind/$bigBlind';
  }
}

class Participant {
  final int id;
  final String status;
  final int? finalTablePosition;
  final User? user;

  Participant({
    required this.id,
    required this.status,
    this.finalTablePosition,
    this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      status: json['status'] ?? 'playing',
      finalTablePosition: json['final_table_position'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Prize {
  final int id;
  final int position;
  final double percentage;
  final double? amount;

  Prize({
    required this.id,
    required this.position,
    required this.percentage,
    this.amount,
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['id'],
      position: json['position'] ?? 1,
      percentage: (json['percentage'] ?? 0).toDouble(),
      amount: json['amount']?.toDouble(),
    );
  }
}

class User {
  final int id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class AppBuyIn {
  final String action;
  final String price;
  final String chips;
  final String totalPrizepool;

  AppBuyIn({
    required this.action,
    required this.price,
    required this.chips,
    required this.totalPrizepool,
  });

  factory AppBuyIn.fromJson(Map<String, dynamic> json) {
    return AppBuyIn(
      action: json['action'] ?? '',
      price: json['price'] ?? '',
      chips: json['chips'] ?? '',
      totalPrizepool: json['total_prizepool'] ?? '',
    );
  }
}

class AppPrize {
  final String description;

  AppPrize({
    required this.description,
  });

  factory AppPrize.fromJson(Map<String, dynamic> json) {
    return AppPrize(
      description: json['description'] ?? '',
    );
  }
}
