class MedicineInfo {
  final String code;
  final String name;
  final String dosage;
  final String form;
  final String? manufacturer;
  final String? activeIngredient;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String? storageConditions;
  final String? pregnancyWarning;
  final String? drivingWarning;

  MedicineInfo({
    required this.code,
    required this.name,
    required this.dosage,
    required this.form,
    this.manufacturer,
    this.activeIngredient,
    this.indications = const [],
    this.contraindications = const [],
    this.sideEffects = const [],
    this.storageConditions,
    this.pregnancyWarning,
    this.drivingWarning,
  });

  factory MedicineInfo.fromJson(Map<String, dynamic> json) {
    return MedicineInfo(
      code: json['code'],
      name: json['name'],
      dosage: json['dosage'],
      form: json['form'],
      manufacturer: json['manufacturer'],
      activeIngredient: json['activeIngredient'],
      indications: json['indications'] != null
          ? List<String>.from(json['indications'])
          : [],
      contraindications: json['contraindications'] != null
          ? List<String>.from(json['contraindications'])
          : [],
      sideEffects: json['sideEffects'] != null
          ? List<String>.from(json['sideEffects'])
          : [],
      storageConditions: json['storageConditions'],
      pregnancyWarning: json['pregnancyWarning'],
      drivingWarning: json['drivingWarning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'dosage': dosage,
      'form': form,
      'manufacturer': manufacturer,
      'activeIngredient': activeIngredient,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'storageConditions': storageConditions,
      'pregnancyWarning': pregnancyWarning,
      'drivingWarning': drivingWarning,
    };
  }
}