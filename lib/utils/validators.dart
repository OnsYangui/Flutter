class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email invalide';
    }
    return null;
  }

  // Validation mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Min 6 caractères';
    }
    return null;
  }

  // Validation confirmation mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Validation téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }
    if (value.length < 10) {
      return 'Téléphone invalide';
    }
    return null;
  }

  // Validation nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }
    if (value.length < 2) {
      return 'Nom trop court';
    }
    return null;
  }

  // Validation glycémie
  static String? validateGlycemia(String? value) {
    if (value == null || value.isEmpty) return null;
    final glycemia = double.tryParse(value);
    if (glycemia == null) return 'Valeur invalide';
    if (glycemia < 20 || glycemia > 600) return 'Valeur hors limites (20-600)';
    return null;
  }

  // Validation tension
  static String? validateBloodPressure(String? systolic, String? diastolic) {
    if (systolic == null || systolic.isEmpty || diastolic == null || diastolic.isEmpty) {
      return 'Tension requise';
    }
    final sys = int.tryParse(systolic);
    final dias = int.tryParse(diastolic);
    if (sys == null || dias == null) return 'Valeurs invalides';
    if (sys < 50 || sys > 250) return 'Systolique invalide (50-250)';
    if (dias < 30 || dias > 150) return 'Diastolique invalide (30-150)';
    if (sys < dias) return 'Systolique doit être > diastolique';
    return null;
  }

  // Validation poids
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final weight = double.tryParse(value);
    if (weight == null) return 'Valeur invalide';
    if (weight < 20 || weight > 300) return 'Poids hors limites (20-300 kg)';
    return null;
  }

  // Validation taille
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final height = double.tryParse(value);
    if (height == null) return 'Valeur invalide';
    if (height < 50 || height > 250) return 'Taille hors limites (50-250 cm)';
    return null;
  }

  // Validation température
  static String? validateTemperature(String? value) {
    if (value == null || value.isEmpty) return null;
    final temp = double.tryParse(value);
    if (temp == null) return 'Valeur invalide';
    if (temp < 34 || temp > 42) return 'Température hors limites (34-42°C)';
    return null;
  }

  // Validation saturation oxygène
  static String? validateOxygenSaturation(String? value) {
    if (value == null || value.isEmpty) return null;
    final saturation = int.tryParse(value);
    if (saturation == null) return 'Valeur invalide';
    if (saturation < 70 || saturation > 100) return 'Saturation hors limites (70-100%)';
    return null;
  }

  // Validation dosage médicament
  static String? validateDosage(String? value) {
    if (value == null || value.isEmpty) return 'Dosage requis';
    final match = RegExp(r'^\d+(\.\d+)?\s*(mg|g|ml|UI|µg)$').hasMatch(value);
    if (!match) return 'Format: "500 mg"';
    return null;
  }

  // Validation date
  static String? validateFutureDate(DateTime? date, String fieldName) {
    if (date == null) return '$fieldName requis';
    if (date.isBefore(DateTime.now())) return '$fieldName doit être dans le futur';
    return null;
  }

  static String? validatePastDate(DateTime? date, String fieldName) {
    if (date == null) return '$fieldName requis';
    if (date.isAfter(DateTime.now())) return '$fieldName doit être dans le passé';
    return null;
  }
}