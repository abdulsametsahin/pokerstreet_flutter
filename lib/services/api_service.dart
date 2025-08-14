import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_event.dart';
import '../models/personal_voucher.dart';
import '../models/event.dart';

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
    Map<String, dynamic> data, {
    File? avatarFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.updateProfileEndpoint),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Debug logging
      print('UpdateProfile - Data: $data');
      print('UpdateProfile - Avatar file: ${avatarFile?.path}');

      // Add text fields
      if (data['display_name'] != null) {
        request.fields['display_name'] = data['display_name'].toString();
        print('Added display_name: ${data['display_name']}');
      }

      if (data['password'] != null) {
        request.fields['password'] = data['password'].toString();
        request.fields['password_confirmation'] =
            data['password_confirmation'].toString();
      }

      if (data['current_password'] != null) {
        request.fields['current_password'] =
            data['current_password'].toString();
      }

      // Add avatar file if provided
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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

  static Future<ApiResponse<List<PersonalVoucher>>> getPersonalVouchers(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.personalVouchersEndpoint),
        headers: ApiConfig.authHeaders(token),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> vouchersJson = jsonResponse['data']['vouchers'];
        final vouchers =
            vouchersJson.map((json) => PersonalVoucher.fromJson(json)).toList();

        return ApiResponse<List<PersonalVoucher>>(
          success: jsonResponse['success'],
          message: jsonResponse['message'],
          data: vouchers,
        );
      } else {
        return ApiResponse<List<PersonalVoucher>>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get personal vouchers',
        );
      }
    } catch (e) {
      return ApiResponse<List<PersonalVoucher>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Event>> getEventDetails(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/mobile/events/$eventId'),
        headers: ApiConfig
            .headers, // Remove auth headers since it's a public endpoint
      );

      final jsonResponse = jsonDecode(response.body);

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final eventData = jsonResponse['event'];
        if (eventData != null) {
          debugPrint("Parsing event from: $eventData");
          try {
            final event = Event.fromJson(eventData);
            return ApiResponse<Event>(
              success: jsonResponse['success'],
              message: jsonResponse['message'] ?? 'Event details retrieved',
              data: event,
            );
          } catch (parseError) {
            debugPrint("Error parsing event JSON: $parseError");
            debugPrint("Event data keys: ${eventData.keys.toList()}");
            return ApiResponse<Event>(
              success: false,
              message: 'Failed to parse event data: ${parseError.toString()}',
            );
          }
        } else {
          debugPrint("Event data is null in response");
          return ApiResponse<Event>(
            success: false,
            message: 'Event data is missing from response',
          );
        }
      } else {
        return ApiResponse<Event>(
          success: false,
          message: jsonResponse['message'] ?? 'Failed to get event details',
        );
      }
    } catch (e) {
      debugPrint("Error in getEventDetails: $e");
      return ApiResponse<Event>(
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

  static Future<ApiResponse<dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPasswordEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      return ApiResponse<dynamic>(
        success: jsonResponse['success'] ?? false,
        message: jsonResponse['message'] ?? 'New password sent to your email',
        errors: jsonResponse['errors'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
