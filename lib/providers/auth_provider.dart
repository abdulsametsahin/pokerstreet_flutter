import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/api_response.dart';
import '../models/user_event.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;
  String? _token;
  User? _user;
  bool _isLoading = false;
  List<UserEvent> _userEvents = [];
  bool _eventsLoading = false;

  AuthProvider(this._prefs) {
    _loadAuthData();
  }

  // Getters
  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  List<UserEvent> get userEvents => _userEvents;
  bool get eventsLoading => _eventsLoading;
  bool get isAuthenticated => _token != null && _user != null;

  // Load auth data from storage
  void _loadAuthData() {
    _token = _prefs.getString(_tokenKey);
    final userData = _prefs.getString(_userKey);
    if (userData != null) {
      try {
        final userJson = Map<String, dynamic>.from(
          // Simple JSON parsing for stored user data
          _parseUserData(userData),
        );
        _user = User.fromJson(userJson);
      } catch (e) {
        // Clear invalid user data
        _clearAuthData();
      }
    }
    notifyListeners();
  }

  // Simple JSON parsing helper
  Map<String, dynamic> _parseUserData(String userData) {
    // This is a simplified parser - in a real app, you'd use dart:convert
    final parts = userData.split('|');
    if (parts.length >= 3) {
      return {
        'id': int.tryParse(parts[0]) ?? 0,
        'name': parts[1],
        'email': parts[2],
        'display_name': parts.length > 3 ? parts[3] : null,
      };
    }
    return {};
  }

  // Save auth data to storage
  Future<void> _saveAuthData(String token, User user) async {
    await _prefs.setString(_tokenKey, token);
    // Simple string format: id|name|email|display_name
    await _prefs.setString(_userKey,
        '${user.id}|${user.name}|${user.email}|${user.displayName ?? ''}');
    _token = token;
    _user = user;
    notifyListeners();
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    _token = null;
    _user = null;
    notifyListeners();
  }

  // Login
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        await _saveAuthData(
          response.data!.token,
          response.data!.user,
        );
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Register
  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        await _saveAuthData(
          response.data!.token,
          response.data!.user,
        );
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Get profile
  Future<ApiResponse<ProfileResponse>> getProfile() async {
    if (_token == null) {
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'No authentication token',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getProfile(_token!);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        // Update stored user data
        await _prefs.setString(
          _userKey,
          '${_user!.id}|${_user!.name}|${_user!.email}|${_user!.displayName ?? ''}',
        );
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'Failed to get profile: ${e.toString()}',
      );
    }
  }

  // Update profile
  Future<ApiResponse<ProfileResponse>> updateProfile(
      Map<String, dynamic> data) async {
    if (_token == null) {
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'No authentication token',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateProfile(_token!, data);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        // Update stored user data
        await _prefs.setString(
          _userKey,
          '${_user!.id}|${_user!.name}|${_user!.email}|${_user!.displayName ?? ''}',
        );
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    if (_token != null) {
      await ApiService.logout(_token!);
    }
    await _clearAuthData();
  }

  // Get user events
  Future<ApiResponse<UserEventsResponse>> getUserEvents() async {
    if (_token == null) {
      return ApiResponse<UserEventsResponse>(
        success: false,
        message: 'No authentication token',
      );
    }

    _eventsLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getUserEvents(_token!);

      if (response.success && response.data != null) {
        _userEvents = response.data!.events;
      }

      _eventsLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _eventsLoading = false;
      notifyListeners();
      return ApiResponse<UserEventsResponse>(
        success: false,
        message: 'Failed to get events: ${e.toString()}',
      );
    }
  }

  // Delete account (soft delete)
  Future<ApiResponse<void>> deleteAccount() async {
    if (_token == null) {
      return ApiResponse<void>(
        success: false,
        message: 'No authentication token',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.deleteAccount(_token!);

      if (response.success) {
        // Clear auth data after successful deletion
        await _clearAuthData();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ApiResponse<void>(
        success: false,
        message: 'Failed to delete account: ${e.toString()}',
      );
    }
  }
}
