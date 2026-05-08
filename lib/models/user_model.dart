class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final DateTime birthDate;
  final String bloodType;
  final List<String> allergies;
  final List<String> chronicDiseases;
  final String? treatingDoctor;
  final String? doctorPhone;
  final String? doctorEmail;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? address;
  final String? city;
  final String? postalCode;
  final double? weight;
  final double? height;
  final String? bloodPressure;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPremium;
  final String? deviceToken;
  final List<String> notificationsEnabled;
  final Map<String, dynamic>? medicalNotes;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.birthDate,
    required this.bloodType,
    required this.allergies,
    required this.chronicDiseases,
    this.treatingDoctor,
    this.doctorPhone,
    this.doctorEmail,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.address,
    this.city,
    this.postalCode,
    this.weight,
    this.height,
    this.bloodPressure,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isPremium = false,
    this.deviceToken,
    this.notificationsEnabled = const ['medications', 'appointments', 'vitals'],
    this.medicalNotes,
  });

  // Calculer l'âge (null si date de naissance non renseignée)
  int? get age {
    // Si birthDate est le même jour que createdAt, c'est le placeholder par défaut
    if (birthDate.year == createdAt.year &&
        birthDate.month == createdAt.month &&
        birthDate.day == createdAt.day) {
      return null;
    }
    final today = DateTime.now();
    int calculatedAge = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  // Calculer l'IMC
  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      return weight! / ((height! / 100) * (height! / 100));
    }
    return null;
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Non disponible';
    if (bmiValue < 18.5) return 'Insuffisance pondérale';
    if (bmiValue < 25) return 'Poids normal';
    if (bmiValue < 30) return 'Surpoids';
    if (bmiValue < 35) return 'Obésité modérée';
    if (bmiValue < 40) return 'Obésité sévère';
    return 'Obésité morbide';
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'treatingDoctor': treatingDoctor,
      'doctorPhone': doctorPhone,
      'doctorEmail': doctorEmail,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'weight': weight,
      'height': height,
      'bloodPressure': bloodPressure,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPremium': isPremium,
      'deviceToken': deviceToken,
      'notificationsEnabled': notificationsEnabled,
      'medicalNotes': medicalNotes,
    };
  }

  factory UserModel.fromFirebaseMap(Map<dynamic, dynamic> map, String id) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : DateTime.now(),
      bloodType: map['bloodType'] ?? 'A+',
      allergies: parseList(map['allergies']),
      chronicDiseases: parseList(map['chronicDiseases']),
      treatingDoctor: map['treatingDoctor'],
      doctorPhone: map['doctorPhone'],
      doctorEmail: map['doctorEmail'],
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      emergencyContactRelation: map['emergencyContactRelation'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postalCode'],
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      bloodPressure: map['bloodPressure'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      isPremium: map['isPremium'] == true,
      deviceToken: map['deviceToken'],
      notificationsEnabled: parseList(map['notificationsEnabled']),
      medicalNotes: map['medicalNotes'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? bloodType,
    List<String>? allergies,
    List<String>? chronicDiseases,
    String? treatingDoctor,
    String? doctorPhone,
    String? doctorEmail,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? address,
    String? city,
    String? postalCode,
    double? weight,
    double? height,
    String? bloodPressure,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    String? deviceToken,
    List<String>? notificationsEnabled,
    Map<String, dynamic>? medicalNotes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      treatingDoctor: treatingDoctor ?? this.treatingDoctor,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      doctorEmail: doctorEmail ?? this.doctorEmail,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPremium: isPremium ?? this.isPremium,
      deviceToken: deviceToken ?? this.deviceToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      medicalNotes: medicalNotes ?? this.medicalNotes,
    );
  }
}