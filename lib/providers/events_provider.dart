import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/events_service.dart';
import 'dart:async';

class EventsProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  Stream<List<Event>>? get eventsStream => _eventsStreamController.stream;
  final StreamController<List<Event>> _eventsStreamController =
      StreamController<List<Event>>.broadcast();

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Event> get runningEvents => _events
      .where((event) => event.isRunning || event.status == 'paused')
      .toList();

  List<Event> get upcomingEvents =>
      _events.where((event) => event.isUpcoming).toList();

  List<Event> get pausedEvents =>
      _events.where((event) => event.status == 'paused').toList();

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _eventsStreamController.add(_events);

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

  @override
  void dispose() {
    _eventsStreamController.close();
    super.dispose();
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
