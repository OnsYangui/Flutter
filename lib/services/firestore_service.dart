import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import '../models/prescription_model.dart';
import '../models/vital_sign_model.dart';
import '../models/consultation_model.dart';
import '../models/alert_model.dart';
import '../models/medical_record_model.dart';
import '../models/hospital_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;

  FirestoreService(this._authService);

  String? get _userId => _authService.currentUser?.id;

  Stream<List<Medication>> getMedications() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Medication>> getActiveMedicationsForToday() {
    return getMedications();
  }

  Future<void> addMedication(Medication medication) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medication.id)
        .set(medication.toMap());
  }

  Future<void> updateMedication(Medication medication) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medication.id)
        .update(medication.toMap());
  }

  Future<void> deleteMedication(String medicationId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .delete();
  }

  Future<void> markMedicationAsTaken(
      String medicationId, DateTime takenAt) async {
    if (_userId == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      List<String> takenHistory = List<String>.from(data['takenHistory'] ?? []);
      takenHistory.add(takenAt.toIso8601String());
      await docRef.update({
        'lastTakenAt': takenAt.toIso8601String(),
        'takenHistory': takenHistory,
      });
    }
  }

  Stream<List<Prescription>> getPrescriptions() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('prescriptions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prescription.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addPrescription(Prescription prescription) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('prescriptions')
        .doc(prescription.id)
        .set(prescription.toMap());
  }

  Future<void> updatePrescription(Prescription prescription) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('prescriptions')
        .doc(prescription.id)
        .update(prescription.toMap());
  }

  Future<void> deletePrescription(String prescriptionId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('prescriptions')
        .doc(prescriptionId)
        .delete();
  }

  Stream<List<VitalSign>> getVitalSigns({VitalSignType? type, int? limit}) {
    if (_userId == null) return Stream.value([]);
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('vitalSigns')
        .orderBy('measuredAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => VitalSign.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addVitalSign(VitalSign vitalSign) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('vitalSigns')
        .doc(vitalSign.id)
        .set(vitalSign.toMap());
  }

  Future<void> deleteVitalSign(String vitalSignId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('vitalSigns')
        .doc(vitalSignId)
        .delete();
  }

  Future<List<VitalSign>> getVitalSignsByDateRange(
    VitalSignType type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userId == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('vitalSigns')
        .where('type', isEqualTo: type.name)
        .where('measuredAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('measuredAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('measuredAt')
        .get();
    return snapshot.docs
        .map((doc) => VitalSign.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Consultation>> getConsultations() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('consultations')
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Consultation.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Consultation>> getUpcomingConsultations() {
    return getConsultations();
  }

  Future<void> addConsultation(Consultation consultation) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('consultations')
        .doc(consultation.id)
        .set(consultation.toMap());
  }

  Future<void> updateConsultation(Consultation consultation) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('consultations')
        .doc(consultation.id)
        .update(consultation.toMap());
  }

  Future<void> deleteConsultation(String consultationId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('consultations')
        .doc(consultationId)
        .delete();
  }

  Stream<List<Alert>> getActiveAlerts() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('alerts')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alert.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addAlert(Alert alert) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('alerts')
        .doc(alert.id)
        .set(alert.toMap());
  }

  Future<void> markAlertAsRead(String alertId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('alerts')
        .doc(alertId)
        .update({'isRead': true});
  }

  Stream<List<MedicalRecord>> getMedicalRecords() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicalRecords')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicalRecords')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<void> deleteMedicalRecord(String recordId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicalRecords')
        .doc(recordId)
        .delete();
  }

  Future<Map<String, dynamic>> getStatistics(
      DateTime startDate, DateTime endDate) async {
    return {
      'totalVitals': 0,
      'activeMedications': 0,
      'consultationsCount': 0,
      'averageGlucose': 0.0,
      'medicationAdherence': 0.0,
    };
  }

  Stream<List<Hospital>> getHospitals() {
    return _firestore
        .collection('hospitals')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Hospital.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Doctor>> getDoctors({String? specialty, String? hospitalId}) {
    Query query = _firestore.collection('doctors');

    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialty', isEqualTo: specialty);
    }

    if (hospitalId != null && hospitalId.isNotEmpty) {
      query = query.where('hospitalId', isEqualTo: hospitalId);
    }

    return query.orderBy('lastName').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addSampleData() async {
    final batch = _firestore.batch();

    final hospital1Ref = _firestore.collection('hospitals').doc();
    batch.set(hospital1Ref, {
      'name': 'Hôpital Central',
      'address': '123 Rue de la Santé, Paris',
      'phone': '+33 1 23 45 67 89',
      'email': 'contact@hopital-central.fr',
      'website': 'https://hopital-central.fr',
      'latitude': 48.8566,
      'longitude': 2.3522,
      'specialties': ['Cardiologie', 'Neurologie', 'Pédiatrie'],
      'isEmergency': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final hospital2Ref = _firestore.collection('hospitals').doc();
    batch.set(hospital2Ref, {
      'name': 'Clinique du Parc',
      'address': '45 Avenue des Fleurs, Lyon',
      'phone': '+33 4 56 78 90 12',
      'email': 'info@cliniqueparc.fr',
      'website': 'https://cliniqueparc.fr',
      'latitude': 45.7640,
      'longitude': 4.8357,
      'specialties': ['Dermatologie', 'Ophtalmologie', 'Gynécologie'],
      'isEmergency': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final doctor1Ref = _firestore.collection('doctors').doc();
    batch.set(doctor1Ref, {
      'firstName': 'Jean',
      'lastName': 'Dupont',
      'specialty': 'Cardiologie',
      'hospitalId': hospital1Ref.id,
      'hospitalName': 'Hôpital Central',
      'phone': '+33 1 23 45 67 90',
      'email': 'jean.dupont@hopital-central.fr',
      'availableDays': ['Monday', 'Tuesday', 'Wednesday', 'Friday'],
      'consultationFee': 50.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final doctor2Ref = _firestore.collection('doctors').doc();
    batch.set(doctor2Ref, {
      'firstName': 'Marie',
      'lastName': 'Martin',
      'specialty': 'Pédiatrie',
      'hospitalId': hospital1Ref.id,
      'hospitalName': 'Hôpital Central',
      'phone': '+33 1 23 45 67 91',
      'email': 'marie.martin@hopital-central.fr',
      'availableDays': ['Tuesday', 'Thursday', 'Saturday'],
      'consultationFee': 45.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
