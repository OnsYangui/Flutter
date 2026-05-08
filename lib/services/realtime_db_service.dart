import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hospital_model.dart';
import '../models/medication_model.dart';
import '../models/vital_sign_model.dart';
import '../models/consultation_model.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';

class RealtimeDbService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final DatabaseReference _hospitalsRef;
  late final DatabaseReference _doctorsRef;
  late final DatabaseReference _medicationsRef;
  late final DatabaseReference _vitalsRef;
  late final DatabaseReference _consultationsRef;
  late final DatabaseReference _medicalRecordsRef;
  late final DatabaseReference _prescriptionsRef;

  RealtimeDbService() {
    _hospitalsRef = _db.ref('hospitals');
    _doctorsRef = _db.ref('doctors');
    _medicationsRef = _db.ref('medications');
    _vitalsRef = _db.ref('vitalSigns');
    _consultationsRef = _db.ref('consultations');
    _medicalRecordsRef = _db.ref('medicalRecords');
    _prescriptionsRef = _db.ref('prescriptions');
  }

  String? get _userId => _auth.currentUser?.uid;

  // --- Hospitals & Doctors ---

  Stream<List<Hospital>> getHospitals() {
    return _hospitalsRef.onValue.asBroadcastStream().map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final hospitals = data.entries.map((entry) {
        return Hospital.fromMap(
            Map<String, dynamic>.from(entry.value as Map), entry.key);
      }).toList();

      hospitals.sort((a, b) => a.name.compareTo(b.name));
      return hospitals;
    });
  }

  Stream<List<Doctor>> getDoctors({String? specialty, String? hospitalId}) {
    return _doctorsRef.onValue.asBroadcastStream().map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      var doctors = data.entries.map((entry) {
        return Doctor.fromMap(
            Map<String, dynamic>.from(entry.value as Map), entry.key);
      }).toList();

      if (specialty != null && specialty.isNotEmpty) {
        doctors = doctors.where((doc) => doc.specialty == specialty).toList();
      }

      if (hospitalId != null && hospitalId.isNotEmpty) {
        doctors = doctors.where((doc) => doc.hospitalId == hospitalId).toList();
      }

      doctors.sort((a, b) => a.lastName.compareTo(b.lastName));
      return doctors;
    });
  }

  Future<void> addHospital(Hospital hospital) async {
    final newRef = _hospitalsRef.push();
    final data = hospital.toMap();
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
  }

  Future<void> addDoctor(Doctor doctor) async {
    final newRef = _doctorsRef.push();
    final data = doctor.toMap();
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
  }

  // --- Medications ---

  Stream<List<Medication>> getMedications() {
    if (_userId == null) return Stream.value([]);
    return _medicationsRef
        .child(_userId!)
        .onValue
        .asBroadcastStream()
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final list = data.entries.map((entry) {
        var mapData = Map<String, dynamic>.from(entry.value as Map);
        mapData['id'] = entry.key; // ensure id matches key
        return Medication.fromMap(mapData);
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addMedication(Medication medication) async {
    if (_userId == null) return;
    final newRef = _medicationsRef.child(_userId!).push();
    var data = medication.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
    await addMedicalRecordAction(
      title: 'Ajout de médicament',
      description: 'Médicament ${medication.name} ajouté avec succès',
      category: 'medication',
      tags: ['médicament', medication.name],
    );
  }

  Future<void> updateMedication(Medication medication) async {
    if (_userId == null || medication.id.isEmpty) return;
    var data = medication.toMap();
    data.removeWhere((key, value) => value == null);
    await _medicationsRef.child(_userId!).child(medication.id).update(data);
  }

  Future<void> deleteMedication(String medicationId) async {
    if (_userId == null) return;
    await _medicationsRef.child(_userId!).child(medicationId).remove();
  }

  Future<void> markMedicationAsTaken(
      String medicationId, DateTime takenAt) async {
    if (_userId == null) return;
    final ref = _medicationsRef.child(_userId!).child(medicationId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final medication = Medication.fromMap(data);
      final updatedHistory = [...medication.takenHistory, takenAt];
      await ref.update({
        'lastTakenAt': takenAt.toIso8601String(),
        'takenHistory': updatedHistory.map((t) => t.toIso8601String()).toList(),
      });
    }
  }

  // --- Vital Signs ---

  Stream<List<VitalSign>> getVitalSigns({VitalSignType? type, int? limit}) {
    if (_userId == null) return Stream.value([]);
    return _vitalsRef.child(_userId!).onValue.asBroadcastStream().map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      var list = data.entries.map((entry) {
        var mapData = Map<String, dynamic>.from(entry.value as Map);
        mapData['id'] = entry.key;
        return VitalSign.fromMap(mapData);
      }).toList();

      if (type != null) {
        list = list.where((v) => v.type == type).toList();
      }

      list.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));

      if (limit != null && list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    });
  }

  Future<void> addVitalSign(VitalSign vitalSign) async {
    if (_userId == null) return;
    final newRef = _vitalsRef.child(_userId!).push();
    var data = vitalSign.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
    await addMedicalRecordAction(
      title: 'Enregistrement de constante',
      description:
          'Constante ${vitalSign.type.label} enregistrée: ${vitalSign.value} ${vitalSign.type.unit}',
      category: 'vital',
      tags: ['constante', vitalSign.type.label],
    );
  }

  Future<void> deleteVitalSign(String vitalSignId) async {
    if (_userId == null) return;
    await _vitalsRef.child(_userId!).child(vitalSignId).remove();
  }

  // --- Consultations ---

  Stream<List<Consultation>> getConsultations({bool upcomingOnly = false}) {
    if (_userId == null) return Stream.value([]);
    return _consultationsRef
        .child(_userId!)
        .onValue
        .asBroadcastStream()
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      var list = data.entries.map((entry) {
        var mapData = Map<String, dynamic>.from(entry.value as Map);
        mapData['id'] = entry.key;
        return Consultation.fromMap(mapData);
      }).toList();

      if (upcomingOnly) {
        list = list.where((c) => c.isUpcoming).toList();
      }

      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return list;
    });
  }

  Future<void> addConsultation(Consultation consultation) async {
    if (_userId == null) return;
    final newRef = _consultationsRef.child(_userId!).push();
    var data = consultation.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
    await addMedicalRecordAction(
      title: 'Ajout de rendez-vous',
      description:
          'Rendez-vous avec ${consultation.doctorName} prévu le ${consultation.scheduledAt}',
      category: 'consultation',
      tags: ['rendez-vous', consultation.doctorName],
    );
  }

  Future<void> updateConsultation(Consultation consultation) async {
    if (_userId == null || consultation.id.isEmpty) return;
    var data = consultation.toMap();
    data.removeWhere((key, value) => value == null);
    await _consultationsRef.child(_userId!).child(consultation.id).update(data);
  }

  Future<void> deleteConsultation(String consultationId) async {
    if (_userId == null) return;
    await _consultationsRef.child(_userId!).child(consultationId).remove();
  }

  // --- Prescriptions ---

  Stream<List<Prescription>> getPrescriptions() {
    if (_userId == null) return Stream.value([]);
    return _prescriptionsRef
        .child(_userId!)
        .onValue
        .asBroadcastStream()
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final list = data.entries.map((entry) {
        var mapData = Map<String, dynamic>.from(entry.value as Map);
        mapData['id'] = entry.key;
        return Prescription.fromMap(mapData);
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addPrescription(Prescription prescription) async {
    if (_userId == null) return;
    final newRef = _prescriptionsRef.child(_userId!).push();
    var data = prescription.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
    await addMedicalRecordAction(
      title: 'Ajout d\'ordonnance',
      description: 'Ordonnance du ${prescription.doctorName} enregistrée',
      category: 'prescription',
      tags: ['ordonnance', prescription.doctorName],
    );
  }

  Future<void> updatePrescription(Prescription prescription) async {
    if (_userId == null || prescription.id.isEmpty) return;
    var data = prescription.toMap();
    data.removeWhere((key, value) => value == null);
    await _prescriptionsRef.child(_userId!).child(prescription.id).update(data);
  }

  Future<void> deletePrescription(String prescriptionId) async {
    if (_userId == null) return;
    await _prescriptionsRef.child(_userId!).child(prescriptionId).remove();
  }

  // --- Medical Records (History) ---

  Stream<List<MedicalRecord>> getMedicalRecords() {
    if (_userId == null) return Stream.value([]);
    return _medicalRecordsRef
        .child(_userId!)
        .onValue
        .asBroadcastStream()
        .map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final list = data.entries.map((entry) {
        var mapData = Map<String, dynamic>.from(entry.value as Map);
        mapData['id'] = entry.key;
        return MedicalRecord.fromMap(mapData);
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addMedicalRecordAction({
    required String title,
    required String description,
    String? category,
    List<String> tags = const [],
    String? hospitalName,
    String? doctorName,
  }) async {
    if (_userId == null) return;
    final record = MedicalRecord(
      id: '',
      title: title,
      description: description,
      fileType: 'document',
      recordDate: DateTime.now(),
      tags: tags,
      category: category,
      hospitalName: hospitalName,
      doctorName: doctorName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final newRef = _medicalRecordsRef.child(_userId!).push();
    var data = record.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    if (_userId == null) return;
    final newRef = _medicalRecordsRef.child(_userId!).push();
    var data = record.toMap();
    data['id'] = newRef.key;
    data.removeWhere((key, value) => value == null);
    await newRef.set(data);
  }

  Future<void> deleteMedicalRecord(String recordId) async {
    if (_userId == null) return;
    await _medicalRecordsRef.child(_userId!).child(recordId).remove();
  }

  // --- Sample Data ---

  Future<void> addSampleData() async {
    final hospital1Ref = _hospitalsRef.push();
    await hospital1Ref.set({
      'name': 'Hôpital Central',
      'address': '123 Rue de la Santé, Paris',
      'phone': '+33 1 23 45 67 89',
      'email': 'contact@hopital-central.fr',
      'website': 'https://hopital-central.fr',
      'latitude': 48.8566,
      'longitude': 2.3522,
      'specialties': ['Cardiologie', 'Neurologie', 'Pédiatrie'],
      'isEmergency': true,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final doctor1Ref = _doctorsRef.push();
    await doctor1Ref.set({
      'firstName': 'Jean',
      'lastName': 'Dupont',
      'specialty': 'Cardiologie',
      'hospitalId': hospital1Ref.key,
      'hospitalName': 'Hôpital Central',
      'phone': '+33 1 23 45 67 90',
      'email': 'jean.dupont@hopital-central.fr',
      'availableDays': ['Monday', 'Tuesday', 'Wednesday', 'Friday'],
      'consultationFee': 50.0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
