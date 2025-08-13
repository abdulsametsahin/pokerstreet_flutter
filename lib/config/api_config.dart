class ApiConfig {
  // Change this to your Laravel API base URL
  static const String baseUrl = 'https://7deb40b7c974.ngrok-free.app/api';
  static const String mobileBaseUrl = '$baseUrl/mobile';

  // Auth endpoints
  static const String loginEndpoint = '$mobileBaseUrl/auth/login';
  static const String registerEndpoint = '$mobileBaseUrl/auth/register';
  static const String profileEndpoint = '$mobileBaseUrl/auth/profile';
  static const String updateProfileEndpoint =
      '$mobileBaseUrl/auth/profile/update';
  static const String userEventsEndpoint = '$mobileBaseUrl/auth/events';
  static const String personalVouchersEndpoint =
      '$mobileBaseUrl/auth/personal-vouchers';
  static const String logoutEndpoint = '$mobileBaseUrl/auth/logout';
  static const String logoutAllEndpoint = '$mobileBaseUrl/auth/logout-all';
  static const String deleteAccountEndpoint =
      '$mobileBaseUrl/auth/delete-account';

  // Public endpoints
  static const String topPlayersEndpoint = '$mobileBaseUrl/top-players';
  static const String availableMonthsEndpoint =
      '$mobileBaseUrl/top-players/months';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
