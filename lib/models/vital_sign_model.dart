import 'dart:convert';
import 'package:flutter/material.dart';

enum VitalSignType {
  bloodGlucose,
  bloodPressure,
  heartRate,
  weight,
  temperature,
  oxygenSaturation,
  cholesterol,
  hba1c;

  String get label {
    switch (this) {
      case VitalSignType.bloodGlucose:
        return 'Glycémie';
      case VitalSignType.bloodPressure:
        return 'Tension artérielle';
      case VitalSignType.heartRate:
        return 'Fréquence cardiaque';
      case VitalSignType.weight:
        return 'Poids';
      case VitalSignType.temperature:
        return 'Température';
      case VitalSignType.oxygenSaturation:
        return 'Saturation O2';
      case VitalSignType.cholesterol:
        return 'Cholestérol';
      case VitalSignType.hba1c:
        return 'Hémoglobine glyquée';
    }
  }

  String get unit {
    switch (this) {
      case VitalSignType.bloodGlucose:
        return 'mg/dL';
      case VitalSignType.bloodPressure:
        return 'mmHg';
      case VitalSignType.heartRate:
        return 'bpm';
      case VitalSignType.weight:
        return 'kg';
      case VitalSignType.temperature:
        return '°C';
      case VitalSignType.oxygenSaturation:
        return '%';
      case VitalSignType.cholesterol:
        return 'mg/dL';
      case VitalSignType.hba1c:
        return '%';
    }
  }

  IconData get icon {
    switch (this) {
      case VitalSignType.bloodGlucose:
        return Icons.bloodtype;
      case VitalSignType.bloodPressure:
        return Icons.favorite;
      case VitalSignType.heartRate:
        return Icons.favorite_border;
      case VitalSignType.weight:
        return Icons.monitor_weight;
      case VitalSignType.temperature:
        return Icons.thermostat;
      case VitalSignType.oxygenSaturation:
        return Icons.air;
      case VitalSignType.cholesterol:
        return Icons.science;
      case VitalSignType.hba1c:
        return Icons.bloodtype;
    }
  }

  (double, double) get normalRange {
    switch (this) {
      case VitalSignType.bloodGlucose:
        return (70, 140);
      case VitalSignType.bloodPressure:
        return (90, 120);
      case VitalSignType.heartRate:
        return (60, 100);
      case VitalSignType.weight:
        return (0, 0);
      case VitalSignType.temperature:
        return (36.5, 37.5);
      case VitalSignType.oxygenSaturation:
        return (95, 100);
      case VitalSignType.cholesterol:
        return (125, 200);
      case VitalSignType.hba1c:
        return (4, 5.7);
    }
  }
}

class VitalSign {
  final String id;
  final VitalSignType type;
  final dynamic value; // Peut être double ou String pour BP (ex: "120/80")
  final DateTime measuredAt;
  final String? notes;
  final String? userId;
  final Map<String, String>?
      metadata; // Pour stocker info contexte (repas, activité, etc.)
  final DateTime createdAt;

  VitalSign({
    required this.id,
    required this.type,
    required this.value,
    required this.measuredAt,
    this.notes,
    this.userId,
    this.metadata,
    required this.createdAt,
  });

  // Pour la tension artérielle (valeur spéciale)
  Map<String, int>? get bloodPressureComponents {
    if (type == VitalSignType.bloodPressure && value is String) {
      final parts = (value as String).split('/');
      if (parts.length == 2) {
        return {
          'systolic': int.tryParse(parts[0]) ?? 0,
          'diastolic': int.tryParse(parts[1]) ?? 0,
        };
      }
    }
    return null;
  }

  // Vérifier si la valeur est dans la normale
  bool get isInNormalRange {
    if (type == VitalSignType.bloodPressure) {
      final bp = bloodPressureComponents;
      if (bp != null) {
        final systolicOk = bp['systolic']! >= (type.normalRange.$1) &&
            bp['systolic']! <= (type.normalRange.$2);
        final diastolicOk = bp['diastolic']! >= 60 && bp['diastolic']! <= 80;
        return systolicOk && diastolicOk;
      }
    } else if (value is double || value is int) {
      final numValue = (value as num).toDouble();
      final (min, max) = type.normalRange;
      if (min == 0 && max == 0) return true;
      return numValue >= min && numValue <= max;
    }
    return true;
  }

  String get statusText {
    if (isInNormalRange) return 'Normal';
    if (type == VitalSignType.bloodGlucose) {
      final glucoseValue = (value as num).toDouble();
      if (glucoseValue < 70) return 'Hypoglycémie';
      if (glucoseValue > 140) return 'Hyperglycémie';
    }
    return 'Hors norme';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'value': value is num ? value : value.toString(),
      'measuredAt': measuredAt.toIso8601String(),
      'notes': notes,
      'userId': userId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VitalSign.fromMap(Map<String, dynamic> map, [String? id]) {
    dynamic value = map['value'];
    if (value is String) {
      if (map['type'] == VitalSignType.bloodPressure.name) {
        // keep as string for blood pressure
      } else if (value.contains('.')) {
        value = double.tryParse(value) ?? value;
      } else {
        value = int.tryParse(value) ?? value;
      }
    }

    return VitalSign(
      id: id ?? map['id'],
      type: VitalSignType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => VitalSignType.bloodGlucose,
      ),
      value: value,
      measuredAt: DateTime.parse(map['measuredAt']),
      notes: map['notes'],
      userId: map['userId'],
      metadata: map['metadata'] != null
          ? Map<String, String>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
