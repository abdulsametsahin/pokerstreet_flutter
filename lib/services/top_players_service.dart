import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/top_player.dart';

class TopPlayersService {
  static Future<TopPlayersResponse> getTopPlayers({
    String? date,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.topPlayersEndpoint);
      final queryParams = <String, String>{};

      if (date != null) {
        queryParams['date'] = date;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        finalUri,
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return TopPlayersResponse.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch top players');
        }
      } else {
        throw Exception('Failed to load top players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<AvailableMonth>> getAvailableMonths() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.availableMonthsEndpoint),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((month) => AvailableMonth.fromJson(month))
              .toList();
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch available months');
        }
      } else {
        throw Exception(
            'Failed to load available months: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
