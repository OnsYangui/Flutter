import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale = const Locale('fr', 'FR');

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  Locale get locale => _locale;

  void _loadLanguage() {
    String? langCode = _prefs.getString(AppConstants.prefLanguage);
    if (langCode != null) {
      if (langCode == 'en') {
        _locale = const Locale('en', 'US');
      } else if (langCode == 'ar') {
        _locale = const Locale('ar', 'AR');
      } else {
        _locale = const Locale('fr', 'FR');
      }
    } else {
      // Default is French as per main.dart original state
      _locale = const Locale('fr', 'FR');
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    if (langCode == 'en') {
      _locale = const Locale('en', 'US');
    } else if (langCode == 'ar') {
      _locale = const Locale('ar', 'AR');
    } else {
      _locale = const Locale('fr', 'FR');
    }
    await _prefs.setString(AppConstants.prefLanguage, langCode);
    notifyListeners();
  }
}
