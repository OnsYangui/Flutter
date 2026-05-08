import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'auth_service.dart';

class DataService extends ChangeNotifier {
  final AuthService _authService;

  DataService(this._authService);

  String? get _userId => _authService.currentUser?.id;

  // ==================== MÉDICAMENTS ====================

  final StreamController<List<Medication>> _medicationsController =
      StreamController<List<Medication>>.broadcast();
  Stream<List<Medication>> get medicationsStream =>
      _medicationsController.stream;

  // ==================== CONSULTATIONS ====================

  final StreamController<List<Consultation>> _consultationsController =
      StreamController<List<Consultation>>.broadcast();
  Stream<List<Consultation>> get consultationsStream =>
      _consultationsController.stream;

  // ==================== SIGNES VITAUX ====================

  final StreamController<List<VitalSign>> _vitalSignsController =
      StreamController<List<VitalSign>>.broadcast();
  Stream<List<VitalSign>> get vitalSignsStream => _vitalSignsController.stream;

  @override
  void dispose() {
    _medicationsController.close();
    _consultationsController.close();
    _vitalSignsController.close();
    super.dispose();
  }
}
