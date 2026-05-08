enum ConsultationType {
  inPerson,
  video,
  phone;

  String get label {
    switch (this) {
      case ConsultationType.inPerson:
        return 'En présentiel';
      case ConsultationType.video:
        return 'Téléconsultation';
      case ConsultationType.phone:
        return 'Téléphone';
    }
  }
}

enum ConsultationStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  missed;

  String get label {
    switch (this) {
      case ConsultationStatus.scheduled:
        return 'Planifiée';
      case ConsultationStatus.confirmed:
        return 'Confirmée';
      case ConsultationStatus.completed:
        return 'Terminée';
      case ConsultationStatus.cancelled:
        return 'Annulée';
      case ConsultationStatus.missed:
        return 'Manquée';
    }
  }
}

class Consultation {
  final String id;
  final String doctorName;
  final String? doctorId;
  final String? doctorSpecialty;
  final String? doctorPhone;
  final String? doctorEmail;
  final DateTime scheduledAt;
  final DateTime? actualAt;
  final ConsultationType type;
  final ConsultationStatus status;
  final String? location;
  final String? videoLink;
  final List<String> symptoms;
  final List<String> questions;
  final String? doctorNotes;
  final String? diagnosis;
  final List<String> prescriptions;
  final List<String> exams;
  final String? followUpNotes;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.doctorName,
    this.doctorId,
    this.doctorSpecialty,
    this.doctorPhone,
    this.doctorEmail,
    required this.scheduledAt,
    this.actualAt,
    required this.type,
    required this.status,
    this.location,
    this.videoLink,
    required this.symptoms,
    required this.questions,
    this.doctorNotes,
    this.diagnosis,
    this.prescriptions = const [],
    this.exams = const [],
    this.followUpNotes,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming {
    return status == ConsultationStatus.scheduled &&
        scheduledAt.isAfter(DateTime.now());
  }

  bool get isToday {
    return scheduledAt.year == DateTime.now().year &&
        scheduledAt.month == DateTime.now().month &&
        scheduledAt.day == DateTime.now().day;
  }

  Duration get timeUntil {
    return scheduledAt.difference(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'doctorSpecialty': doctorSpecialty,
      'doctorPhone': doctorPhone,
      'doctorEmail': doctorEmail,
      'scheduledAt': scheduledAt.toIso8601String(),
      'actualAt': actualAt?.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'location': location,
      'videoLink': videoLink,
      'symptoms': symptoms,
      'questions': questions,
      'doctorNotes': doctorNotes,
      'diagnosis': diagnosis,
      'prescriptions': prescriptions,
      'exams': exams,
      'followUpNotes': followUpNotes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Consultation copyWith({
    String? id,
    String? doctorName,
    String? doctorId,
    String? doctorSpecialty,
    String? doctorPhone,
    String? doctorEmail,
    DateTime? scheduledAt,
    DateTime? actualAt,
    ConsultationType? type,
    ConsultationStatus? status,
    String? location,
    String? videoLink,
    List<String>? symptoms,
    List<String>? questions,
    String? doctorNotes,
    String? diagnosis,
    List<String>? prescriptions,
    List<String>? exams,
    String? followUpNotes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      doctorId: doctorId ?? this.doctorId,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      doctorEmail: doctorEmail ?? this.doctorEmail,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      actualAt: actualAt ?? this.actualAt,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      videoLink: videoLink ?? this.videoLink,
      symptoms: symptoms ?? this.symptoms,
      questions: questions ?? this.questions,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      diagnosis: diagnosis ?? this.diagnosis,
      prescriptions: prescriptions ?? this.prescriptions,
      exams: exams ?? this.exams,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Consultation.fromMap(Map<String, dynamic> map, [String? id]) {
    return Consultation(
      id: id ?? map['id'],
      doctorName: map['doctorName'],
      doctorId: map['doctorId'],
      doctorSpecialty: map['doctorSpecialty'],
      doctorPhone: map['doctorPhone'],
      doctorEmail: map['doctorEmail'],
      scheduledAt: DateTime.parse(map['scheduledAt']),
      actualAt:
          map['actualAt'] != null ? DateTime.parse(map['actualAt']) : null,
      type: ConsultationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ConsultationType.inPerson,
      ),
      status: ConsultationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConsultationStatus.scheduled,
      ),
      location: map['location'],
      videoLink: map['videoLink'],
      symptoms: (map['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      questions: (map['questions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      doctorNotes: map['doctorNotes'],
      diagnosis: map['diagnosis'],
      prescriptions: (map['prescriptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      exams:
          (map['exams'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      followUpNotes: map['followUpNotes'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class ConsultationPreparation {
  final String id;
  final String consultationId;
  final List<String> symptoms;
  final List<String> questions;
  final Map<String, dynamic> lastVitals;
  final List<String> medicationsToDiscuss;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultationPreparation({
    required this.id,
    required this.consultationId,
    required this.symptoms,
    required this.questions,
    required this.lastVitals,
    required this.medicationsToDiscuss,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'symptoms': symptoms,
      'questions': questions,
      'lastVitals': lastVitals,
      'medicationsToDiscuss': medicationsToDiscuss,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ConsultationPreparation.fromMap(Map<String, dynamic> map) {
    return ConsultationPreparation(
      id: map['id'],
      consultationId: map['consultationId'],
      symptoms: List<String>.from(map['symptoms']),
      questions: List<String>.from(map['questions']),
      lastVitals: Map<String, dynamic>.from(map['lastVitals']),
      medicationsToDiscuss: List<String>.from(map['medicationsToDiscuss']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
