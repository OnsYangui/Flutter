enum PrescriptionStatus {
  active,
  expired,
  archived;

  String get label {
    switch (this) {
      case PrescriptionStatus.active:
        return 'Active';
      case PrescriptionStatus.expired:
        return 'Expirée';
      case PrescriptionStatus.archived:
        return 'Archivée';
    }
  }
}

class Prescription {
  final String id;
  final String doctorName;
  final String? doctorId;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? pharmacy;
  final String? pharmacyPhone;
  final String? notes;
  final String? imageUrl;
  final String? pdfUrl;
  final PrescriptionStatus status;
  final String? userId;
  final List<String> medicationIds;
  final String? originalText;
  final String? translatedText;
  final String? detectedLanguage;
  final String? targetLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.doctorName,
    this.doctorId,
    required this.issueDate,
    this.expiryDate,
    this.pharmacy,
    this.pharmacyPhone,
    this.notes,
    this.imageUrl,
    this.pdfUrl,
    required this.status,
    this.userId,
    required this.medicationIds,
    this.originalText,
    this.translatedText,
    this.detectedLanguage,
    this.targetLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return -1;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'pharmacy': pharmacy,
      'pharmacyPhone': pharmacyPhone,
      'notes': notes,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'status': status.name,
      'userId': userId,
      'medicationIds': medicationIds,
      'originalText': originalText,
      'translatedText': translatedText,
      'detectedLanguage': detectedLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map, [String? id]) {
    return Prescription(
      id: id ?? map['id'],
      doctorName: map['doctorName'],
      doctorId: map['doctorId'],
      issueDate: DateTime.parse(map['issueDate']),
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      pharmacy: map['pharmacy'],
      pharmacyPhone: map['pharmacyPhone'],
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      pdfUrl: map['pdfUrl'],
      status: PrescriptionStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => PrescriptionStatus.active,
      ),
      userId: map['userId'],
      medicationIds: List<String>.from(map['medicationIds'] ?? []),
      originalText: map['originalText'],
      translatedText: map['translatedText'],
      detectedLanguage: map['detectedLanguage'],
      targetLanguage: map['targetLanguage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}