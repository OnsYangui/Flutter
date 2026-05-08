import 'package:flutter/material.dart';

enum MedicationType {
  pill,
  injection,
  inhaler,
  drop,
  cream,
  syrup,
  other;

  String get label {
    switch (this) {
      case MedicationType.pill:
        return 'Comprimé';
      case MedicationType.injection:
        return 'Injection';
      case MedicationType.inhaler:
        return 'Inhalateur';
      case MedicationType.drop:
        return 'Gouttes';
      case MedicationType.cream:
        return 'Crème';
      case MedicationType.syrup:
        return 'Sirop';
      case MedicationType.other:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationType.pill:
        return Icons.medication;
      case MedicationType.injection:
        return Icons.medical_information;
      case MedicationType.inhaler:
        return Icons.air;
      case MedicationType.drop:
        return Icons.water_drop;
      case MedicationType.cream:
        return Icons.spa;
      case MedicationType.syrup:
        return Icons.science;
      case MedicationType.other:
        return Icons.medication_liquid;
    }
  }

  Color get color {
    switch (this) {
      case MedicationType.pill:
        return Colors.blue;
      case MedicationType.injection:
        return Colors.red;
      case MedicationType.inhaler:
        return Colors.green;
      case MedicationType.drop:
        return Colors.purple;
      case MedicationType.cream:
        return Colors.orange;
      case MedicationType.syrup:
        return Colors.teal;
      case MedicationType.other:
        return Colors.grey;
    }
  }
}

enum MedicationStatus {
  pending,
  taken,
  skipped,
  missed;

  String get label {
    switch (this) {
      case MedicationStatus.pending:
        return 'En attente';
      case MedicationStatus.taken:
        return 'Pris';
      case MedicationStatus.skipped:
        return 'Sauté';
      case MedicationStatus.missed:
        return 'Oublié';
    }
  }

  Color get color {
    switch (this) {
      case MedicationStatus.pending:
        return Colors.orange;
      case MedicationStatus.taken:
        return Colors.green;
      case MedicationStatus.skipped:
        return Colors.grey;
      case MedicationStatus.missed:
        return Colors.red;
    }
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String unit;
  final MedicationType type;
  final String frequency;
  final List<DateTime> times;
  final int durationDays;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final String prescriptionId;
  final String? userId;
  final List<String>
      daysOfWeek; // ['monday', 'tuesday', ...] pour fréquences spécifiques
  final bool takeWithFood;
  final bool takeBeforeMeal;
  final int? quantity;
  final int? remainingQuantity;
  final String? manufacturer;
  final String? barcode;
  final DateTime? lastTakenAt;
  final List<DateTime> takenHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.type,
    required this.frequency,
    required this.times,
    required this.durationDays,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isActive = true,
    required this.prescriptionId,
    this.userId,
    this.daysOfWeek = const [],
    this.takeWithFood = false,
    this.takeBeforeMeal = false,
    this.quantity,
    this.remainingQuantity,
    this.manufacturer,
    this.barcode,
    this.lastTakenAt,
    this.takenHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Vérifier si le médicament doit être pris aujourd'hui
  bool get shouldTakeToday {
    if (!isActive) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);

    if (endDate != null) {
      final endDateOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (todayDate.isBefore(startDateOnly) || todayDate.isAfter(endDateOnly)) {
        return false;
      }
    } else {
      if (todayDate.isBefore(startDateOnly)) {
        return false;
      }
    }

    if (daysOfWeek.isNotEmpty) {
      final currentDay = today.weekdayToString();
      return daysOfWeek.contains(currentDay);
    }
    return true;
  }

  // Prochaine prise
  DateTime? get nextDose {
    final now = DateTime.now();
    final futureTimes = times.where((time) => time.isAfter(now)).toList();
    if (futureTimes.isNotEmpty) {
      return futureTimes.first;
    }
    // Prochain jour
    final nextDay = now.add(const Duration(days: 1));
    final firstTime =
        times.isNotEmpty ? times.first : DateTime(now.year, now.month, now.day);
    return DateTime(nextDay.year, nextDay.month, nextDay.day, firstTime.hour,
        firstTime.minute);
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? unit,
    MedicationType? type,
    String? frequency,
    List<DateTime>? times,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    String? prescriptionId,
    String? userId,
    List<String>? daysOfWeek,
    bool? takeWithFood,
    bool? takeBeforeMeal,
    int? quantity,
    int? remainingQuantity,
    String? manufacturer,
    String? barcode,
    DateTime? lastTakenAt,
    List<DateTime>? takenHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      userId: userId ?? this.userId,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      takeWithFood: takeWithFood ?? this.takeWithFood,
      takeBeforeMeal: takeBeforeMeal ?? this.takeBeforeMeal,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      manufacturer: manufacturer ?? this.manufacturer,
      barcode: barcode ?? this.barcode,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
      takenHistory: takenHistory ?? this.takenHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'unit': unit,
      'type': type.name,
      'frequency': frequency,
      'times': times.map((t) => t.toIso8601String()).toList(),
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'prescriptionId': prescriptionId,
      'userId': userId,
      'daysOfWeek': daysOfWeek,
      'takeWithFood': takeWithFood,
      'takeBeforeMeal': takeBeforeMeal,
      'quantity': quantity,
      'remainingQuantity': remainingQuantity,
      'manufacturer': manufacturer,
      'barcode': barcode,
      'lastTakenAt': lastTakenAt?.toIso8601String(),
      'takenHistory': takenHistory.map((t) => t.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, [String? id]) {
    List<T> parseList<T>(dynamic value, T Function(dynamic) parser) {
      if (value == null) return [];
      if (value is List) {
        return value.map(parser).toList();
      }
      return [];
    }

    return Medication(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      unit: map['unit'] ?? 'mg',
      type: MedicationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MedicationType.other,
      ),
      frequency: map['frequency'] ?? 'Une fois par jour',
      times: parseList(map['times'], (t) => DateTime.parse(t.toString())),
      durationDays: map['durationDays'] ?? 30,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
      isActive: map['isActive'] == true || map['isActive'] == 1,
      prescriptionId: map['prescriptionId'] ?? '',
      userId: map['userId'],
      daysOfWeek: parseList(map['daysOfWeek'], (d) => d.toString()),
      takeWithFood: map['takeWithFood'] == true || map['takeWithFood'] == 1,
      takeBeforeMeal:
          map['takeBeforeMeal'] == true || map['takeBeforeMeal'] == 1,
      quantity:
          map['quantity'] != null ? (map['quantity'] as num).toInt() : null,
      remainingQuantity: map['remainingQuantity'] != null
          ? (map['remainingQuantity'] as num).toInt()
          : null,
      manufacturer: map['manufacturer'],
      barcode: map['barcode'],
      lastTakenAt: map['lastTakenAt'] != null
          ? DateTime.parse(map['lastTakenAt'])
          : null,
      takenHistory:
          parseList(map['takenHistory'], (t) => DateTime.parse(t.toString())),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }
}

extension DateTimeExtension on DateTime {
  String weekdayToString() {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return '';
    }
  }
}
