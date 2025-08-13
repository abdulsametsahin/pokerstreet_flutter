import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner.dart' as BannerModel;
import '../config/api_config.dart';

class BannerService {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Future<List<BannerModel.Banner>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mobile/banners'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> bannersJson = data['data'];
          return bannersJson
              .map((json) => BannerModel.Banner.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load banners');
        }
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading banners: $e');
    }
  }

  static Future<BannerModel.Banner> getBanner(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mobile/banners/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return BannerModel.Banner.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load banner');
        }
      } else {
        throw Exception('Failed to load banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading banner: $e');
    }
  }
}
