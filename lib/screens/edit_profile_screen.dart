import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _treatingDoctorController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _doctorEmailController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();

  late DateTime _birthDate;
  late String _bloodType;
  final List<String> _allergies = [];
  final List<String> _chronicDiseases = [];
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _chronicDiseaseController =
      TextEditingController();

  String? _profileImageUrl;
  XFile? _selectedImage;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone;
      _birthDate = user.birthDate;
      _bloodType = user.bloodType;
      _allergies.addAll(user.allergies);
      _chronicDiseases.addAll(user.chronicDiseases);
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _postalCodeController.text = user.postalCode ?? '';
      _weightController.text = user.weight?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
      _bloodPressureController.text = user.bloodPressure ?? '';
      _treatingDoctorController.text = user.treatingDoctor ?? '';
      _doctorPhoneController.text = user.doctorPhone ?? '';
      _doctorEmailController.text = user.doctorEmail ?? '';
      _emergencyContactNameController.text = user.emergencyContactName ?? '';
      _emergencyContactPhoneController.text = user.emergencyContactPhone ?? '';
      _emergencyContactRelationController.text =
          user.emergencyContactRelation ?? '';
      _profileImageUrl = user.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodPressureController.dispose();
    _treatingDoctorController.dispose();
    _doctorPhoneController.dispose();
    _doctorEmailController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationController.dispose();
    _allergyController.dispose();
    _chronicDiseaseController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text);
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  void _addChronicDisease() {
    if (_chronicDiseaseController.text.isNotEmpty) {
      setState(() {
        _chronicDiseases.add(_chronicDiseaseController.text);
        _chronicDiseaseController.clear();
      });
    }
  }

  void _removeChronicDisease(String disease) {
    setState(() {
      _chronicDiseases.remove(disease);
    });
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _storageService.takePhoto();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _storageService.pickImageFromGallery();
                if (image != null) {
                  setState(() {
                    _selectedImage = image;
                  });
                }
              },
            ),
            if (_profileImageUrl != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Supprimer la photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _profileImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isLoading) {
            return const LoadingIndicator(message: 'Sauvegarde...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo de profil
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(File(_selectedImage!.path))
                                  : (_profileImageUrl != null
                                      ? FileImage(File(_profileImageUrl!))
                                      : null),
                              child: _selectedImage == null &&
                                      _profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 20),
                                  onPressed: _pickProfileImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: _pickProfileImage,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Modifier la photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Informations personnelles
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  InkWell(
                    onTap: _selectBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de naissance',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                          '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: _bloodType,
                    decoration: const InputDecoration(
                      labelText: 'Groupe sanguin',
                      prefixIcon: Icon(Icons.water_drop),
                      border: OutlineInputBorder(),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _bloodType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Adresse
                  const Text(
                    'Adresse',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Code postal',
                            prefixIcon: Icon(Icons.pin),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Informations médicales
                  const Text(
                    'Informations médicales',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Poids (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Taille (cm)',
                            prefixIcon: Icon(Icons.height),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(
                      labelText: 'Tension artérielle (ex: 120/80)',
                      prefixIcon: Icon(Icons.favorite),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Allergies
                  const Text('Allergies',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    children: _allergies
                        .map((allergy) => Chip(
                              label: Text(allergy),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => _removeAllergy(allergy),
                            ))
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allergyController,
                          decoration: const InputDecoration(
                            labelText: 'Ajouter une allergie',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addAllergy,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Maladies chroniques
                  const Text('Maladies chroniques',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    children: _chronicDiseases
                        .map((disease) => Chip(
                              label: Text(disease),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => _removeChronicDisease(disease),
                            ))
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chronicDiseaseController,
                          decoration: const InputDecoration(
                            labelText: 'Ajouter une maladie chronique',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addChronicDisease,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Médecin traitant
                  const Text(
                    'Médecin traitant',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _treatingDoctorController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du médecin',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _doctorPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone du médecin',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _doctorEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email du médecin',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Contact d'urgence
                  const Text(
                    'Contact d\'urgence',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _emergencyContactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du contact',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _emergencyContactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone du contact',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _emergencyContactRelationController,
                    decoration: const InputDecoration(
                      labelText: 'Lien avec vous',
                      prefixIcon: Icon(Icons.family_restroom),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  CustomButton(
                    text: 'Sauvegarder',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String? finalProfileImageUrl = _profileImageUrl;

                        // Upload new image if selected
                        if (_selectedImage != null) {
                          finalProfileImageUrl =
                              await _storageService.uploadImage(
                            image: _selectedImage!,
                            userId: authService.currentUser!.id,
                            type: 'profile',
                          );
                        }

                        final user = UserModel(
                          id: authService.currentUser!.id,
                          email: authService.currentUser!.email,
                          fullName: _fullNameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          birthDate: _birthDate,
                          bloodType: _bloodType,
                          allergies: _allergies,
                          chronicDiseases: _chronicDiseases,
                          address: _addressController.text.isNotEmpty
                              ? _addressController.text.trim()
                              : null,
                          city: _cityController.text.isNotEmpty
                              ? _cityController.text.trim()
                              : null,
                          postalCode: _postalCodeController.text.isNotEmpty
                              ? _postalCodeController.text.trim()
                              : null,
                          weight: _weightController.text.isNotEmpty
                              ? double.tryParse(_weightController.text)
                              : null,
                          height: _heightController.text.isNotEmpty
                              ? double.tryParse(_heightController.text)
                              : null,
                          bloodPressure:
                              _bloodPressureController.text.isNotEmpty
                                  ? _bloodPressureController.text.trim()
                                  : null,
                          treatingDoctor:
                              _treatingDoctorController.text.isNotEmpty
                                  ? _treatingDoctorController.text.trim()
                                  : null,
                          doctorPhone: _doctorPhoneController.text.isNotEmpty
                              ? _doctorPhoneController.text.trim()
                              : null,
                          doctorEmail: _doctorEmailController.text.isNotEmpty
                              ? _doctorEmailController.text.trim()
                              : null,
                          emergencyContactName:
                              _emergencyContactNameController.text.isNotEmpty
                                  ? _emergencyContactNameController.text.trim()
                                  : null,
                          emergencyContactPhone:
                              _emergencyContactPhoneController.text.isNotEmpty
                                  ? _emergencyContactPhoneController.text.trim()
                                  : null,
                          emergencyContactRelation:
                              _emergencyContactRelationController
                                      .text.isNotEmpty
                                  ? _emergencyContactRelationController.text
                                      .trim()
                                  : null,
                          profileImageUrl: finalProfileImageUrl,
                          createdAt: authService.currentUser!.createdAt,
                          updatedAt: DateTime.now(),
                          isPremium: authService.currentUser!.isPremium,
                          deviceToken: authService.currentUser?.deviceToken,
                          notificationsEnabled:
                              authService.currentUser!.notificationsEnabled,
                          medicalNotes: authService.currentUser?.medicalNotes,
                        );

                        final success =
                            await authService.updateUserProfile(user);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil mis à jour'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erreur lors de la mise à jour'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
