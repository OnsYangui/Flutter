import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class Helpers {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  // Formatage de date
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      return "Il y a ${(difference.inDays / 7).floor()} semaines";
    } else if (difference.inDays < 365) {
      return "Il y a ${(difference.inDays / 30).floor()} mois";
    } else {
      return formatDate(date);
    }
  }

  // Validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^(\+?[0-9]{10,14})$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Calculs médicaux
  static double calculateBMI(double weight, double height) {
    return weight / pow(height / 100, 2);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    if (bmi < 35) return 'Obésité modérée';
    if (bmi < 40) return 'Obésité sévère';
    return 'Obésité morbide';
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.accent;
    if (bmi < 35) return AppColors.abnormal;
    if (bmi < 40) return AppColors.highPriority;
    return AppColors.critical;
  }

  static double calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age.toDouble();
  }

  // Adhérence médicamenteuse
  static double calculateAdherence(List<DateTime> takenTimes, List<DateTime> expectedTimes) {
    if (expectedTimes.isEmpty) return 100.0;
    final taken = takenTimes.where((t) => expectedTimes.any((e) => e.day == t.day)).length;
    return (taken / expectedTimes.length) * 100;
  }

  // Statistiques
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double calculateStandardDeviation(List<double> values, double mean) {
    if (values.isEmpty) return 0;
    final squaredSum = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    return sqrt(squaredSum / values.length);
  }

  static double getTrend(List<double> values) {
    if (values.length < 2) return 0;
    final first = values.first;
    final last = values.last;
    return ((last - first) / first) * 100;
  }

  // Génération d'ID unique
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Formatage des valeurs médicales
  static String formatBloodPressure(int systolic, int diastolic) {
    return '$systolic/$diastolic mmHg';
  }

  static String formatGlycemia(double value) {
    return '${value.toStringAsFixed(0)} mg/dL';
  }

  static String formatTemperature(double value) {
    return '${value.toStringAsFixed(1)}°C';
  }

  // Extensions pour les couleurs
  static Color getStatusColor(bool isNormal) {
    return isNormal ? AppColors.success : AppColors.error;
  }

  // Gestion des erreurs
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return AppConstants.errorGeneric;
  }

  // Debounce pour les recherches
  static Function debounce(Function func, Duration duration) {
    Timer? timer;
    return () {
      if (timer != null) timer!.cancel();
      timer = Timer(duration, () => func());
    };
  }

  // Vérifier si un DateTime est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Obtenir le début de la semaine
  static DateTime getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  // Obtenir la fin de la semaine
  static DateTime getEndOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.add(Duration(days: 7 - dayOfWeek));
  }

  // Obtenir le début du mois
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Obtenir la fin du mois
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}