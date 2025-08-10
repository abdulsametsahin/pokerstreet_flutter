import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';

  final SharedPreferences _prefs;
  Locale _locale = const Locale('en');

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isLithuanian => _locale.languageCode == 'lt';

  void _loadLocale() {
    final localeCode = _prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(localeCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  List<Locale> get supportedLocales => const [
        Locale('en'),
        Locale('lt'),
      ];
}
