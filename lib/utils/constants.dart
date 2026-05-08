import 'package:flutter/material.dart';

class AppConstants {
  // Application
  static const String appName = 'MediAssist';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.mediassist.app';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String medicationsCollection = 'medications';
  static const String prescriptionsCollection = 'prescriptions';
  static const String vitalSignsCollection = 'vitalSigns';
  static const String consultationsCollection = 'consultations';
  static const String alertsCollection = 'alerts';
  static const String medicalRecordsCollection = 'medicalRecords';

  // Shared Preferences Keys
  static const String prefUserLoggedIn = 'user_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastBackup = 'last_backup';

  // API Keys (à mettre dans un fichier séparé non commité)
  static const String googleMapsApiKey = 'YOUR_API_KEY';
  static const String openFdaApiKey = 'YOUR_API_KEY';

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration autoBackupInterval = Duration(days: 7);

  // Limits
  static const int maxRecentMedications = 10;
  static const int maxVitalSignsHistory = 100;
  static const int maxBackupFiles = 5;
  static const int maxImageSizeMB = 5;

  // Blood types
  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  // Medication frequencies
  static const List<String> frequencies = [
    'Une fois par jour',
    'Deux fois par jour',
    'Trois fois par jour',
    'Quatre fois par jour',
    'Toutes les heures',
    'Toutes les 2 heures',
    'Toutes les 4 heures',
    'Toutes les 6 heures',
    'Toutes les 8 heures',
    'Toutes les 12 heures',
  ];

  // Notification channels
  static const String medicationChannelId = 'medication_channel';
  static const String medicationChannelName = 'Rappels de médicaments';
  static const String medicationChannelDescription =
      'Notifications pour les rappels de prise de médicaments';

  static const String appointmentChannelId = 'appointment_channel';
  static const String appointmentChannelName = 'Rappels de rendez-vous';
  static const String appointmentChannelDescription =
      'Notifications pour les rappels de consultations';

  static const String vitalChannelId = 'vital_channel';
  static const String vitalChannelName = 'Rappels de constantes';
  static const String vitalChannelDescription =
      'Notifications pour les rappels de mesures';

  static const String generalChannelId = 'general_channel';
  static const String generalChannelName = 'Notifications générales';
  static const String generalChannelDescription =
      'Notifications générales de l\'application';

  // Error messages
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNetwork = 'Problème de connexion internet';
  static const String errorAuth = 'Erreur d\'authentification';
  static const String errorInvalidEmail = 'Email invalide';
  static const String errorWeakPassword = 'Mot de passe trop faible';
  static const String errorPasswordsNotMatch =
      'Les mots de passe ne correspondent pas';
  static const String errorRequiredField = 'Ce champ est requis';
  static const String errorInvalidPhone = 'Numéro de téléphone invalide';

  // Success messages
  static const String successLogin = 'Connexion réussie';
  static const String successRegister = 'Inscription réussie';
  static const String successLogout = 'Déconnexion réussie';
  static const String successSave = 'Enregistrement réussi';
  static const String successDelete = 'Suppression réussie';
  static const String successBackup = 'Sauvegarde réussie';

  // Medical reference values
  static const Map<String, Map<String, double>> medicalNormalRanges = {
    'glycemia': {'min': 70, 'max': 140},
    'pressureSystolic': {'min': 90, 'max': 120},
    'pressureDiastolic': {'min': 60, 'max': 80},
    'heartRate': {'min': 60, 'max': 100},
    'temperature': {'min': 36.5, 'max': 37.5},
    'oxygenSaturation': {'min': 95, 'max': 100},
    'cholesterol': {'min': 125, 'max': 200},
    'hba1c': {'min': 4, 'max': 5.7},
  };
}

class AppColors {
  // Primary colors (Teal medical scheme – matching template)
  static const Color primary = Color(0xFF00BCD4); // Teal Cyan
  static const Color primaryLight = Color(0xFF4DD0E1);
  static const Color primaryDark = Color(0xFF0097A7);

  // Secondary colors
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryDark = Color(0xFF475569);

  // Accent colors
  static const Color accent = Color(0xFFFDE68A);
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color accentDark = Color(0xFFF59E0B);

  // Success/Status colors
  static const Color success = Color(0xFF34D399);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFF87171);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFFF7ED);

  // Vital signs colors
  static const Color normal = Color(0xFF10B981);
  static const Color abnormal = Color(0xFFF59E0B);
  static const Color critical = Color(0xFFEF4444);

  // Priority colors
  static const Color lowPriority = Color(0xFF10B981);
  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color highPriority = Color(0xFFF97316);
  static const Color criticalPriority = Color(0xFFEF4444);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1F2937);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  // Backward compatibility
  static const Color grey = Color(0xFF9CA3AF);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF4B5563);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color medicalTeal = Color(0xFF00BCD4);

}

class AppFontSizes {
  static const double displayLarge = 57;
  static const double displayMedium = 45;
  static const double displaySmall = 36;

  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;

  static const double titleLarge = 20;
  static const double titleMedium = 18;
  static const double titleSmall = 16;

  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;

  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 11;
}

class AppSpacing {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppBorderRadius {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(32));
  static const BorderRadius circular = BorderRadius.all(Radius.circular(999));
}
