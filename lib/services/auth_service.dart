import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _authStateController.stream;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null && _currentUser == null) {
        _isLoading = true;
        notifyListeners();
        _isLoggedIn = true;
        await _fetchUserProfile(user.uid);
        _isLoading = false;
        _authStateController.add(_isLoggedIn);
        notifyListeners();
      } else if (user == null) {
        _isLoggedIn = false;
        _currentUser = null;
        _isLoading = false;
        _authStateController.add(_isLoggedIn);
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final snapshot = await _usersRef.child(uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _currentUser = UserModel.fromFirebaseMap(data, uid);
      }
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la récupération du profil : $e");
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = userCredential.user!.uid;

      final user = UserModel(
        id: uid,
        email: email.trim(),
        fullName: '$firstName $lastName',
        phone: '',
        birthDate: DateTime.now(),
        bloodType: 'A+',
        allergies: [],
        chronicDiseases: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremium: false,
        notificationsEnabled: ['medications', 'appointments', 'vitals'],
      );

      await _usersRef.child(uid).set(user.toFirebaseMap());

      _currentUser = user;
      _isLoggedIn = true;

      _authStateController.add(true);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Un compte existe déjà avec cet email.';
      } else {
        _errorMessage = 'Erreur: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Une erreur est survenue: $e";
      print("Erreur register: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = "Aucun utilisateur trouvé pour cet email.";
      } else if (e.code == 'wrong-password') {
        _errorMessage = "Mot de passe incorrect.";
      } else {
        _errorMessage = "Identifiants invalides.";
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Une erreur est survenue: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de la réinitialisation: $e";
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "Utilisateur non connecté";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = "Mot de passe actuel incorrect ou erreur: ${e.message}";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Une erreur est survenue: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _errorMessage = "Utilisateur non connecté";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _usersRef.child(user.uid).remove();
      await user.delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de la suppression: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromFirebaseMap(data, userId);
      }
      return null;
    } catch (e) {
      print('Erreur: $e');
      return null;
    }
  }

  Future<UserModel?> getUserProfile() async {
    return _currentUser;
  }

  Future<bool> updateUserProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_auth.currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final uid = _auth.currentUser!.uid;
      final updates = {
        'fullName': user.fullName,
        'phone': user.phone,
        'birthDate': user.birthDate.toIso8601String(),
        'bloodType': user.bloodType,
        'allergies': user.allergies,
        'chronicDiseases': user.chronicDiseases,
        'treatingDoctor': user.treatingDoctor,
        'doctorPhone': user.doctorPhone,
        'doctorEmail': user.doctorEmail,
        'emergencyContactName': user.emergencyContactName,
        'emergencyContactPhone': user.emergencyContactPhone,
        'emergencyContactRelation': user.emergencyContactRelation,
        'address': user.address,
        'city': user.city,
        'postalCode': user.postalCode,
        'weight': user.weight,
        'height': user.height,
        'bloodPressure': user.bloodPressure,
        'profileImageUrl': user.profileImageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
        'notificationsEnabled': user.notificationsEnabled,
      };

      updates.removeWhere((key, value) => value == null);

      await _usersRef.child(uid).update(updates);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur updateUserProfile: $e");
      _errorMessage = "Erreur lors de la mise à jour du profil: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
