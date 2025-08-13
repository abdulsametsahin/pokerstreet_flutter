import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_event.dart';

class ApiService {
  static Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<AuthResponse>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: AuthResponse.fromJson(jsonResponse['data']),
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Login failed',
          errors: jsonResponse['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<AuthResponse>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: AuthResponse.fromJson(jsonResponse['data']),
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Registration failed',
          errors: jsonResponse['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<ProfileResponse>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: ApiConfig.authHeaders(token),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<ProfileResponse>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: ProfileResponse.fromJson(jsonResponse['data']),
        );
      } else {
        return ApiResponse<ProfileResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<ProfileResponse>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.updateProfileEndpoint),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(data),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<ProfileResponse>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: ProfileResponse.fromJson(jsonResponse['data']),
        );
      } else {
        return ApiResponse<ProfileResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to update profile',
          errors: jsonResponse['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<ProfileResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<void>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.logoutEndpoint),
        headers: ApiConfig.authHeaders(token),
      );

      final jsonResponse = jsonDecode(response.body);

      return ApiResponse<void>(
        success: jsonResponse['success'] ?? false,
        message: jsonResponse['message'] ?? 'Logout completed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<UserEventsResponse>> getUserEvents(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userEventsEndpoint),
        headers: ApiConfig.authHeaders(token),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UserEventsResponse>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: UserEventsResponse.fromJson(jsonResponse['data']),
        );
      } else {
        return ApiResponse<UserEventsResponse>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get events',
        );
      }
    } catch (e) {
      return ApiResponse<UserEventsResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<void>> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteAccountEndpoint),
        headers: ApiConfig.authHeaders(token),
      );

      final jsonResponse = jsonDecode(response.body);

      return ApiResponse<void>(
        success: jsonResponse['success'] ?? false,
        message: jsonResponse['message'] ?? 'Account deletion completed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
