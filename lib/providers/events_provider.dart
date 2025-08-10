import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/events_service.dart';

class EventsProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Event> get runningEvents =>
      _events.where((event) => event.isRunning).toList();

  List<Event> get upcomingEvents =>
      _events.where((event) => event.isUpcoming).toList();

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await EventsService.getPublicEvents();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event?> loadEvent(int eventId) async {
    try {
      return await EventsService.getEvent(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void refreshEvents() {
    loadEvents();
  }
}
