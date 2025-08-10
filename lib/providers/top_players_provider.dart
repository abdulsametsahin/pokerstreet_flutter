import 'package:flutter/foundation.dart';
import '../models/top_player.dart';
import '../services/top_players_service.dart';

class TopPlayersProvider with ChangeNotifier {
  List<TopPlayer> _players = [];
  List<AvailableMonth> _availableMonths = [];
  bool _isLoading = false;
  bool _isLoadingMonths = false;
  String? _error;
  String? _selectedDate;
  String _monthName = '';
  int _totalCount = 0;

  List<TopPlayer> get players => _players;
  List<AvailableMonth> get availableMonths => _availableMonths;
  bool get isLoading => _isLoading;
  bool get isLoadingMonths => _isLoadingMonths;
  String? get error => _error;
  String? get selectedDate => _selectedDate;
  String get monthName => _monthName;
  int get totalCount => _totalCount;

  Future<void> loadTopPlayers({String? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TopPlayersService.getTopPlayers(date: date);
      _players = response.players;
      _selectedDate = response.date;
      _monthName = response.monthName;
      _totalCount = response.totalCount;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _players = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableMonths() async {
    _isLoadingMonths = true;
    notifyListeners();

    try {
      _availableMonths = await TopPlayersService.getAvailableMonths();
    } catch (e) {
      _availableMonths = [];
      if (kDebugMode) {
        print('Error loading available months: $e');
      }
    } finally {
      _isLoadingMonths = false;
      notifyListeners();
    }
  }

  void selectMonth(String date) {
    if (_selectedDate != date) {
      loadTopPlayers(date: date);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
