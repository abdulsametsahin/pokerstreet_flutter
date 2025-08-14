import 'package:flutter/material.dart';

class Event {
  final int id;
  final String name;
  final String? description;
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
  final String? backgroundUrl;

  Event({
    required this.id,
    required this.name,
    this.description,
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
    this.backgroundUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    debugPrint("Starting Event.fromJson");

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

    try {
      final id =
          json['id'] is int ? json['id'] : int.parse(json['id'].toString());
      final name = json['name']?.toString() ?? '';
      final description = json['description']?.toString().isEmpty == true
          ? null
          : json['description']?.toString();
      final status = json['status']?.toString() ?? 'upcoming';

      final startsAt = json['starts_at'] != null
          ? DateTime.parse(json['starts_at'].toString())
          : DateTime.now();
      final startedAt = json['started_at'];

      final timeElapsed = _parseInt(json['time_elapsed']);
      final isPublic = json['is_public'] == true;
      final trackRanking = json['track_ranking'] == true;
      final displayPrizePool = json['display_prize_pool'] == true;
      final totalMinutes = _parseInt(json['total_minutes']);
      final remaining = _parseInt(json['remaining']);
      final elapsedTime = _parseDouble(json['elapsed_time']).toInt();
      final activePlayersCount = _parseInt(json['active_players_count']);
      final playersCount = _parseInt(json['players_count']);

      final levels = (json['levels'] as List?)?.map((level) {
            try {
              return Level.fromJson(level);
            } catch (e) {
              debugPrint("Error parsing level: $e, level data: $level");
              rethrow;
            }
          }).toList() ??
          [];

      final participants = (json['participants'] as List?)?.map((participant) {
            try {
              return Participant.fromJson(participant);
            } catch (e) {
              debugPrint(
                  "Error parsing participant: $e, participant data: $participant");
              rethrow;
            }
          }).toList() ??
          [];

      final prizes = (json['prizes'] as List?)?.map((prize) {
            try {
              return Prize.fromJson(prize);
            } catch (e) {
              debugPrint("Error parsing prize: $e, prize data: $prize");
              rethrow;
            }
          }).toList() ??
          [];

      final currentLevel = json['current_level'] != null
          ? Level.fromJson(json['current_level'])
          : null;
      final nextLevel = json['next_level'] != null
          ? Level.fromJson(json['next_level'])
          : null;
      final levelRemaining = _parseDouble(json['level_remaining']).toInt();

      return Event(
        id: id,
        name: name,
        description: description,
        status: status,
        startsAt: startsAt,
        startedAt: startedAt,
        timeElapsed: timeElapsed,
        isPublic: isPublic,
        trackRanking: trackRanking,
        displayPrizePool: displayPrizePool,
        totalMinutes: totalMinutes,
        remaining: remaining,
        elapsedTime: elapsedTime,
        activePlayersCount: activePlayersCount,
        playersCount: playersCount,
        levels: levels,
        participants: participants,
        prizes: prizes,
        currentLevel: currentLevel,
        nextLevel: nextLevel,
        levelRemaining: levelRemaining,
        appBuyIn: appBuyIn,
        appPrizes: appPrizes,
        backgroundUrl: json['background_image']?.toString(),
      );
    } catch (e) {
      debugPrint("Error creating Event: $e");
      rethrow;
    }
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
  final String? description;

  Level({
    required this.id,
    this.levelNumber,
    this.smallBlind,
    this.bigBlind,
    this.ante,
    required this.duration,
    required this.type,
    this.description,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    try {
      return Level(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        levelNumber: json['level_number'],
        smallBlind: json['small_blind'],
        bigBlind: json['big_blind'],
        ante: json['ante'],
        duration: json['duration'] is int
            ? json['duration']
            : int.parse(json['duration']?.toString() ?? '0'),
        type: json['type']?.toString() ?? 'round',
        description: json['description']?.toString().isEmpty == true
            ? null
            : json['description']?.toString(),
      );
    } catch (e) {
      debugPrint("Error in Level.fromJson: $e");
      debugPrint("Level JSON data: $json");
      rethrow;
    }
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
  final int? position;
  final int? finalTablePosition;
  final User? user;

  Participant({
    required this.id,
    required this.status,
    this.position,
    this.finalTablePosition,
    this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    try {
      return Participant(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        status: json['status']?.toString() ?? 'playing',
        position: json['position'],
        finalTablePosition: json['final_table_position'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );
    } catch (e) {
      debugPrint("Error in Participant.fromJson: $e");
      debugPrint("Participant JSON data: $json");
      rethrow;
    }
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
    try {
      return Prize(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        position: json['position'] is int
            ? json['position']
            : int.parse(json['position']?.toString() ?? '1'),
        percentage: (json['percentage'] ?? 0).toDouble(),
        amount: json['amount']?.toDouble(),
      );
    } catch (e) {
      debugPrint("Error in Prize.fromJson: $e");
      debugPrint("Prize JSON data: $json");
      rethrow;
    }
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
    try {
      return User(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint("Error in User.fromJson: $e");
      debugPrint("User JSON data: $json");
      rethrow;
    }
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
