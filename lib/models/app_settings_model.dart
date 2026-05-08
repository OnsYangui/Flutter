class AppSettings {
  final bool notificationsEnabled;
  final bool medicationReminders;
  final bool appointmentReminders;
  final bool vitalReminders;
  final int reminderMinutesBefore;
  final bool darkMode;
  final String language; // 'fr', 'en', 'ar'
  final String fontSize; // 'small', 'medium', 'large'
  final bool dataSaver;
  final bool autoBackup;
  final bool shareAnonymousData;
  final String? backupFrequency; // 'daily', 'weekly', 'monthly'
  final DateTime? lastBackupAt;
  final bool biometricAuth;
  final int autoLockMinutes;
  final bool exportPDFOnConsultation;
  final bool shareWithDoctor;
  final String? defaultDoctorId;
  final Map<String, dynamic> customPreferences;

  AppSettings({
    this.notificationsEnabled = true,
    this.medicationReminders = true,
    this.appointmentReminders = true,
    this.vitalReminders = true,
    this.reminderMinutesBefore = 15,
    this.darkMode = false,
    this.language = 'fr',
    this.fontSize = 'medium',
    this.dataSaver = false,
    this.autoBackup = true,
    this.shareAnonymousData = false,
    this.backupFrequency = 'weekly',
    this.lastBackupAt,
    this.biometricAuth = false,
    this.autoLockMinutes = 5,
    this.exportPDFOnConsultation = true,
    this.shareWithDoctor = false,
    this.defaultDoctorId,
    this.customPreferences = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'medicationReminders': medicationReminders,
      'appointmentReminders': appointmentReminders,
      'vitalReminders': vitalReminders,
      'reminderMinutesBefore': reminderMinutesBefore,
      'darkMode': darkMode,
      'language': language,
      'fontSize': fontSize,
      'dataSaver': dataSaver,
      'autoBackup': autoBackup,
      'shareAnonymousData': shareAnonymousData,
      'backupFrequency': backupFrequency,
      'lastBackupAt': lastBackupAt?.toIso8601String(),
      'biometricAuth': biometricAuth,
      'autoLockMinutes': autoLockMinutes,
      'exportPDFOnConsultation': exportPDFOnConsultation,
      'shareWithDoctor': shareWithDoctor,
      'defaultDoctorId': defaultDoctorId,
      'customPreferences': customPreferences,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      medicationReminders: map['medicationReminders'] ?? true,
      appointmentReminders: map['appointmentReminders'] ?? true,
      vitalReminders: map['vitalReminders'] ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 15,
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'fr',
      fontSize: map['fontSize'] ?? 'medium',
      dataSaver: map['dataSaver'] ?? false,
      autoBackup: map['autoBackup'] ?? true,
      shareAnonymousData: map['shareAnonymousData'] ?? false,
      backupFrequency: map['backupFrequency'] ?? 'weekly',
      lastBackupAt: map['lastBackupAt'] != null
          ? DateTime.parse(map['lastBackupAt'])
          : null,
      biometricAuth: map['biometricAuth'] ?? false,
      autoLockMinutes: map['autoLockMinutes'] ?? 5,
      exportPDFOnConsultation: map['exportPDFOnConsultation'] ?? true,
      shareWithDoctor: map['shareWithDoctor'] ?? false,
      defaultDoctorId: map['defaultDoctorId'],
      customPreferences: map['customPreferences'] ?? {},
    );
  }
}