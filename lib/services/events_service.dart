import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/event.dart';

class EventsService {
  static Future<List<Event>> getPublicEvents() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mobile/events'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['events'] as List)
            .map((event) => Event.fromJson(event))
            .toList();
      }
    }

    throw Exception('Failed to load events');
  }

  static Future<Event> getEvent(int eventId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/mobile/events/$eventId'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Event.fromJson(data['event']);
      }
    }

    throw Exception('Failed to load event');
  }
}
