import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _LocalizedData _localizedValues = _LocalizedData();

  String get appName => _getValue('appName');
  String get login => _getValue('login');
  String get signup => _getValue('signup');
  String get email => _getValue('email');
  String get password => _getValue('password');
  String get forgotPassword => _getValue('forgotPassword');
  String get home => _getValue('home');
  String get medications => _getValue('medications');
  String get appointments => _getValue('appointments');
  String get profile => _getValue('profile');
  String get settings => _getValue('settings');
  String get language => _getValue('language');
  String get logout => _getValue('logout');
  String get save => _getValue('save');
  String get cancel => _getValue('cancel');
  String get edit => _getValue('edit');
  String get delete => _getValue('delete');
  String get add => _getValue('add');
  String get search => _getValue('search');
  String get welcome => _getValue('welcome');
  String get appearance => _getValue('appearance');
  String get darkMode => _getValue('darkMode');
  String get notifications => _getValue('notifications');
  String get sounds => _getValue('sounds');
  String get vibration => _getValue('vibration');
  String get about => _getValue('about');
  String get version => _getValue('version');
  String get medicationReminders => _getValue('medicationReminders');
  String get history => _getValue('history');
  String get backup => _getValue('backup');
  String get personalInfo => _getValue('personalInfo');
  String get medicalInfo => _getValue('medicalInfo');
  String get emergencyContact => _getValue('emergencyContact');
  String get phone => _getValue('phone');
  String get address => _getValue('address');
  String get bloodType => _getValue('bloodType');
  String get allergies => _getValue('allergies');
  String get chronicDiseases => _getValue('chronicDiseases');
  String get none => _getValue('none');
  String get health => _getValue('health');
  String get vitalSigns => _getValue('vitalSigns');
  String get recentMeasurements => _getValue('recentMeasurements');
  String get noData => _getValue('noData');
  String get average => _getValue('average');
  String get hello => _getValue('hello');
  String get searchPlaceholder => _getValue('searchPlaceholder');
  String get upcomingAppointment => _getValue('upcomingAppointment');
  String get seeAll => _getValue('seeAll');
  String get quickHealthCheck => _getValue('quickHealthCheck');
  String get aiAssistant => _getValue('aiAssistant');
  String get todayMedications => _getValue('todayMedications');
  String get meds => _getValue('meds');
  String get consults => _getValue('consults');
  String get vitals => _getValue('vitals');
  String get historyTitle => _getValue('historyTitle');
  String get bookNow => _getValue('bookNow');
  String get noUpcomingAppointments => _getValue('noUpcomingAppointments');
  String get everythingUpToDate => _getValue('everythingUpToDate');
  String get noMedicationsToday => _getValue('noMedicationsToday');
  String get scannerOrdonnance => _getValue('scannerOrdonnance');
  String get scannerCodeBarres => _getValue('scannerCodeBarres');
  String get analyserImage => _getValue('analyserImage');
  String get hopitauxMedecins => _getValue('hopitauxMedecins');
  String get your => _getValue('your');
  String get all => _getValue('all');
  String get active => _getValue('active');
  String get completed => _getValue('completed');
  String get noMedications => _getValue('noMedications');
  String get addFirstMedication => _getValue('addFirstMedication');
  String get searchMedication => _getValue('searchMedication');
  String get manage => _getValue('manage');
  String get upcoming => _getValue('upcoming');
  String get scheduleCheckup => _getValue('scheduleCheckup');
  String get noHistory => _getValue('noHistory');
  String get pastConsultationsAppearHere => _getValue('pastConsultationsAppearHere');

  // French, English, Arabic
  String _getValue(String key) {
    return _localizedValues.data[locale.languageCode]?[key] ?? _localizedValues.data['en']![key]!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _LocalizedData {
  const _LocalizedData();

  final Map<String, Map<String, String>> data = const {
    'en': {
      'appName': 'MediAssist',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'home': 'Home',
      'medications': 'Medications',
      'appointments': 'Appointments',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'add': 'Add',
      'search': 'Search',
      'welcome': 'Welcome',
      'appearance': 'Appearance',
      'darkMode': 'Dark Mode',
      'notifications': 'Notifications',
      'sounds': 'Sounds',
      'vibration': 'Vibration',
      'about': 'About',
      'version': 'Version',
      'medicationReminders': 'Medication Reminders',
      'history': 'History',
      'backup': 'Backup Data',
      'personalInfo': 'Personal Information',
      'medicalInfo': 'Medical Information',
      'emergencyContact': 'Emergency Contact',
      'phone': 'Phone',
      'address': 'Address',
      'bloodType': 'Blood Type',
      'allergies': 'Allergies',
      'chronicDiseases': 'Chronic Diseases',
      'none': 'None',
      'health': 'Health',
      'vitalSigns': 'Vital Signs',
      'recentMeasurements': 'Recent Measurements',
      'noData': 'No data available',
      'average': 'Average',
      'hello': 'Hello',
      'searchPlaceholder': 'Search Doctor, Medication...',
      'upcomingAppointment': 'Upcoming Appointment',
      'seeAll': 'See All',
      'quickHealthCheck': 'Quick Health Check',
      'aiAssistant': 'AI Medical Assistant',
      'todayMedications': 'Today\'s Medications',
      'meds': 'Meds',
      'consults': 'Consults',
      'vitals': 'Vitals',
      'historyTitle': 'History',
      'bookNow': 'Book Now',
      'noUpcomingAppointments': 'No upcoming appointments',
      'everythingUpToDate': 'Everything is up to date!',
      'noMedicationsToday': 'No medications today',
      'scannerOrdonnance': 'Scan Prescription',
      'scannerCodeBarres': 'Scan Barcode',
      'analyserImage': 'Analyze Image',
      'hopitauxMedecins': 'Hospitals & Doctors',
      'your': 'Your',
      'all': 'All',
      'active': 'Active',
      'completed': 'Completed',
      'noMedications': 'No medications',
      'addFirstMedication': 'Add your first medication to stay on track',
      'searchMedication': 'Search Medication...',
      'manage': 'Manage',
      'upcoming': 'Upcoming',
      'scheduleCheckup': 'Schedule your next medical checkup',
      'noHistory': 'No history',
      'pastConsultationsAppearHere': 'Your past consultations will appear here',
    },
    'fr': {
      'appName': 'MediAssist',
      'login': 'Connexion',
      'signup': 'Inscription',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'forgotPassword': 'Mot de passe oublié ?',
      'home': 'Accueil',
      'medications': 'Médicaments',
      'appointments': 'Rendez-vous',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'language': 'Langue',
      'logout': 'Déconnexion',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'add': 'Ajouter',
      'search': 'Rechercher',
      'welcome': 'Bienvenue',
      'appearance': 'Apparence',
      'darkMode': 'Mode sombre',
      'notifications': 'Notifications',
      'sounds': 'Sons',
      'vibration': 'Vibration',
      'about': 'À propos',
      'version': 'Version',
      'medicationReminders': 'Rappels de médicaments',
      'history': 'Historique',
      'backup': 'Sauvegarder les données',
      'personalInfo': 'Informations personnelles',
      'medicalInfo': 'Informations médicales',
      'emergencyContact': 'Contact d\'urgence',
      'phone': 'Téléphone',
      'address': 'Adresse',
      'bloodType': 'Groupe sanguin',
      'allergies': 'Allergies',
      'chronicDiseases': 'Maladies chroniques',
      'none': 'Aucun',
      'health': 'Santé',
      'vitalSigns': 'Constantes',
      'recentMeasurements': 'Mesures récentes',
      'noData': 'Aucune donnée disponible',
      'average': 'Moyenne',
      'hello': 'Bonjour',
      'searchPlaceholder': 'Rechercher médecin, médicament...',
      'upcomingAppointment': 'Prochain rendez-vous',
      'seeAll': 'Voir tout',
      'quickHealthCheck': 'Contrôle de santé rapide',
      'aiAssistant': 'Assistant médical IA',
      'todayMedications': 'Médicaments du jour',
      'meds': 'Médic.',
      'consults': 'Consult.',
      'vitals': 'Const.',
      'historyTitle': 'Hist.',
      'bookNow': 'Réserver',
      'noUpcomingAppointments': 'Aucun rendez-vous à venir',
      'everythingUpToDate': 'Tout est à jour !',
      'noMedicationsToday': 'Aucun médicament aujourd\'hui',
      'scannerOrdonnance': 'Scanner ordonnance',
      'scannerCodeBarres': 'Scanner code-barres',
      'analyserImage': 'Analyser image',
      'hopitauxMedecins': 'Hôpitaux & Médecins',
      'your': 'Vos',
      'all': 'Tout',
      'active': 'En cours',
      'completed': 'Terminé',
      'noMedications': 'Aucun médicament',
      'addFirstMedication': 'Ajoutez votre premier médicament pour rester à jour',
      'searchMedication': 'Rechercher un médicament...',
      'manage': 'Gérer',
      'upcoming': 'À venir',
      'scheduleCheckup': 'Planifiez votre prochain contrôle médical',
      'noHistory': 'Aucun historique',
      'pastConsultationsAppearHere': 'Vos consultations passées apparaîtront ici',
    },
    'ar': {
      'appName': 'ميدي أسيسيت',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgotPassword': 'هل نسيت كلمة المرور؟',
      'home': 'الرئيسية',
      'medications': 'الأدوية',
      'appointments': 'المواعيد',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'edit': 'تعديل',
      'delete': 'حذف',
      'add': 'إضافة',
      'search': 'بحث',
      'welcome': 'مرحباً',
      'appearance': 'المظهر',
      'darkMode': 'الوضع الداكن',
      'notifications': 'الإشعارات',
      'sounds': 'الأصوات',
      'vibration': 'الاهتزاز',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'medicationReminders': 'تذكير بالأدوية',
      'history': 'السجل',
      'backup': 'نسخ البيانات احتياطياً',
      'personalInfo': 'المعلومات الشخصية',
      'medicalInfo': 'المعلومات الطبية',
      'emergencyContact': 'جهة اتصال للطوارئ',
      'phone': 'الهاتف',
      'address': 'العنوان',
      'bloodType': 'فصيلة الدم',
      'allergies': 'الحساسية',
      'chronicDiseases': 'الأمراض المزمنة',
      'none': 'لا يوجد',
      'health': 'الصحة',
      'vitalSigns': 'العلامات الحيوية',
      'recentMeasurements': 'القياسات الأخيرة',
      'noData': 'لا توجد بيانات متاحة',
      'average': 'المعدل',
      'hello': 'مرحباً',
      'searchPlaceholder': 'ابحث عن طبيب، دواء...',
      'upcomingAppointment': 'الموعد القادم',
      'seeAll': 'عرض الكل',
      'quickHealthCheck': 'فحص صحي سريع',
      'aiAssistant': 'مساعد طبي ذكي',
      'todayMedications': 'أدوية اليوم',
      'meds': 'أدوية',
      'consults': 'استشارات',
      'vitals': 'علامات',
      'historyTitle': 'سجل',
      'bookNow': 'احجز الآن',
      'noUpcomingAppointments': 'لا توجد مواعيد قادمة',
      'everythingUpToDate': 'كل شيء على ما يرام!',
      'noMedicationsToday': 'لا توجد أدوية اليوم',
      'scannerOrdonnance': 'مسح الوصفة',
      'scannerCodeBarres': 'مسح الباركود',
      'analyserImage': 'تحليل الصورة',
      'hopitauxMedecins': 'مستشفيات وأطباء',
      'your': 'الخاص بك',
      'all': 'الكل',
      'active': 'نشط',
      'completed': 'مكتمل',
      'noMedications': 'لا توجد أدوية',
      'addFirstMedication': 'أضف أول دواء لك للبقاء على المسار الصحيح',
      'searchMedication': 'ابحث عن دواء...',
      'manage': 'إدارة',
      'upcoming': 'قادم',
      'scheduleCheckup': 'حدد موعد فحصك الطبي القادم',
      'noHistory': 'لا يوجد سجل',
      'pastConsultationsAppearHere': 'ستظهر استشاراتك السابقة هنا',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
