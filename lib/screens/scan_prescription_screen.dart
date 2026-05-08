import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import '../services/ml_kit_service.dart';
import '../services/feedback_service.dart';
import '../services/realtime_db_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import 'prescriptions_screen.dart';
import 'home_screen.dart';
import '../models/medication_model.dart';
import '../models/medicine_info_model.dart';
import '../models/prescription_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/loading_indicator.dart';

class ScanPrescriptionScreen extends StatefulWidget {
  const ScanPrescriptionScreen({super.key});

  @override
  State<ScanPrescriptionScreen> createState() => _ScanPrescriptionScreenState();
}

class _ScanPrescriptionScreenState extends State<ScanPrescriptionScreen> {
  final MLKitService _mlKit = MLKitService();
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;
  bool _isTranslating = false;
  XFile? _selectedImage;
  PrescriptionScanResult? _scanResult;
  List<Medication> _extractedMedications = [];
  List<bool> _selectedMedications = [];
  String _selectedTargetLang = 'fr';

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'und':
        return 'Indétecté';
      default:
        return code;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final feedback = FeedbackService();
    await feedback.vibrate();

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _isScanning = true;
        _selectedImage = image;
        _scanResult = null;
        _extractedMedications = [];
        _selectedMedications = [];
      });

      try {
        final result = await _mlKit.scanPrescription(image);
        setState(() {
          _scanResult = result;
          _extractedMedications = _convertToMedications(result.medications);
          _selectedMedications =
              List.generate(result.medications.length, (index) => true);
          _isScanning = false;
        });

        await feedback.vibrateSuccess();

        if (result.medications.isNotEmpty) {
          _showMedicationsDialog();
        }
      } catch (e) {
        setState(() {
          _isScanning = false;
        });

        await feedback.vibrateError();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du scan de l\'ordonnance: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _translateText() async {
    if (_scanResult == null) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final sourceLang = _mlKit.getLanguageEnum(_scanResult!.language ?? 'fr');
      final targetLang = _mlKit.getLanguageEnum(_selectedTargetLang);

      final translated = await _mlKit.translateText(
        _scanResult!.fullText,
        sourceLang,
        targetLang,
      );

      setState(() {
        _scanResult!.translatedText = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la traduction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<Medication> _convertToMedications(List<MedicineInfo> medInfos) {
    return medInfos.map((info) {
      String unit = '';
      if (info.dosage.isNotEmpty) {
        final parts = info.dosage.split(' ');
        if (parts.length > 1) {
          unit = parts.last;
        }
      }
      return Medication(
        id: Helpers.generateId(),
        name: info.name,
        dosage: info.dosage,
        unit: unit,
        type: MedicationType.pill,
        frequency: 'Une fois par jour',
        times: [DateTime.now()],
        durationDays: 30,
        startDate: DateTime.now(),
        prescriptionId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  void _showMedicationsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Médicaments détectés'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _extractedMedications.length,
                itemBuilder: (context, index) {
                  final med = _extractedMedications[index];
                  return ListTile(
                    leading: const Icon(Icons.medication),
                    title: Text(med.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${med.dosage} - ${med.frequency}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: AppColors.primary),
                          onPressed: () async {
                            final editedMed =
                                await _showEditMedicationDialog(context, med);
                            if (editedMed != null) {
                              setDialogState(() {
                                _extractedMedications[index] = editedMed;
                              });
                              setState(() {
                                _extractedMedications[index] = editedMed;
                              });
                            }
                          },
                        ),
                        Checkbox(
                          value: _selectedMedications[index],
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedMedications[index] = value!;
                            });
                            setState(() {
                              _selectedMedications[index] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final firestoreService =
                      Provider.of<FirestoreService>(context, listen: false);
                  final dbService =
                      Provider.of<RealtimeDbService>(context, listen: false);
                  int addedCount = 0;
                  List<String> medicationIds = [];

                  for (int i = 0; i < _extractedMedications.length; i++) {
                    if (_selectedMedications[i]) {
                      final medication = _extractedMedications[i];
                      await firestoreService.addMedication(medication);
                      await dbService.addMedication(medication);
                      medicationIds.add(medication.id);
                      await NotificationService()
                          .scheduleMedicationReminder(medication);
                      addedCount++;
                    }
                  }

                  if (addedCount > 0) {
                    final prescription = Prescription(
                      id: Helpers.generateId(),
                      doctorName: _scanResult?.doctorName ?? 'Médecin inconnu',
                      issueDate: _scanResult?.date ?? DateTime.now(),
                      status: PrescriptionStatus.active,
                      medicationIds: medicationIds,
                      originalText: _scanResult?.fullText,
                      translatedText: _scanResult?.translatedText,
                      detectedLanguage: _scanResult?.language,
                      targetLanguage: _scanResult?.translatedText != null
                          ? _selectedTargetLang
                          : null,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    await firestoreService.addPrescription(prescription);
                    await dbService.addPrescription(prescription);

                    final selectedMedsNames = _extractedMedications
                        .asMap()
                        .entries
                        .where((entry) => _selectedMedications[entry.key])
                        .map((entry) => entry.value.name)
                        .toList();

                    await dbService.addMedicalRecordAction(
                      title: 'Scan d\'ordonnance',
                      description:
                          '$addedCount médicament(s) ajouté(s) depuis une ordonnance',
                      category: 'prescription',
                      tags: ['ordonnance', 'scan', ...selectedMedsNames],
                    );
                  }

                  Navigator.pop(context); // Fermer le dialogue
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Ordonnance sauvegardée avec $addedCount médicament(s)'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    // Naviguer vers l'onglet Ordonnances (index 2)
                    final homeState =
                        context.findAncestorStateOfType<HomeScreenState>();
                    if (homeState != null) {
                      homeState.switchToTab(2);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context, true);
                    }
                  }
                },
                child: const Text('Sauvegarder l\'ordonnance'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isScanning
          ? const LoadingIndicator(message: 'Analyse de l\'ordonnance...')
          : _selectedImage == null
              ? _buildScanPrompt()
              : _buildScanResult(),
    );
  }

  Widget _buildScanPrompt() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Scanner une ordonnance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Numérisez votre ordonnance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Prenez une photo claire de votre ordonnance.\nNous extrairons les médicaments et les détails pour vous.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey500, fontSize: 16),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _ScanButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Appareil photo',
                  onTap: () => _pickImage(ImageSource.camera),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScanButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Galerie',
                  onTap: () => _pickImage(ImageSource.gallery),
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() {
                        _selectedImage = null;
                        _scanResult = null;
                      }),
                    ),
                    const Text(
                      'Résultat de l\'analyse',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Image Preview
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.lg,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 10),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
                const SizedBox(height: 25),

                if (_scanResult != null) ...[
                  _buildLanguageSection(),
                  const SizedBox(height: 20),
                  _buildTextSection(),
                  const SizedBox(height: 20),
                  if (_scanResult!.medications.isNotEmpty) ...[
                    const Text(
                      'Médicaments détectés',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._scanResult!.medications
                        .map((med) => _SimpleMedCard(med: med)),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton(
                    onPressed: _showMedicationsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.lg),
                    ),
                    child: const Text('Ajouter à mes médicaments'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _savePrescriptionOnly,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.lg),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Sauvegarder l\'ordonnance uniquement'),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Langue détectée: ${_getLanguageName(_scanResult!.language ?? 'und')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_scanResult!.language != null &&
              _scanResult!.language != 'und') ...[
            const Divider(height: 24),
            Row(
              children: [
                const Text('Traduire en : '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTargetLang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedTargetLang = value!),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isTranslating ? null : _translateText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey100,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.md),
                  ),
                  child: _isTranslating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Traduire'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Texte extrait',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            _scanResult!.fullText,
            style: const TextStyle(
                fontFamily: 'monospace', color: AppColors.grey700),
          ),
          if (_scanResult!.translatedText != null) ...[
            const Divider(height: 24),
            const Text('Traduction',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.success)),
            const SizedBox(height: 12),
            Text(
              _scanResult!.translatedText!,
              style: const TextStyle(
                  fontFamily: 'monospace', color: AppColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  Future<Medication?> _showEditMedicationDialog(
      BuildContext context, Medication med) async {
    final nameController = TextEditingController(text: med.name);
    final dosageController = TextEditingController(text: med.dosage);
    final freqController = TextEditingController(text: med.frequency);

    return showDialog<Medication>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le médicament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Dosage')),
            TextField(
                controller: freqController,
                decoration: const InputDecoration(labelText: 'Fréquence')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                context,
                med.copyWith(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: freqController.text,
                )),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePrescriptionOnly() async {
    if (_scanResult == null) return;
    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final dbService = Provider.of<RealtimeDbService>(context, listen: false);
      final prescription = Prescription(
        id: Helpers.generateId(),
        doctorName: _scanResult?.doctorName ?? 'Médecin inconnu',
        issueDate: _scanResult?.date ?? DateTime.now(),
        status: PrescriptionStatus.active,
        medicationIds: [],
        originalText: _scanResult?.fullText,
        translatedText: _scanResult?.translatedText,
        detectedLanguage: _scanResult?.language,
        targetLanguage:
            _scanResult?.translatedText != null ? _selectedTargetLang : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await firestoreService.addPrescription(prescription);
      await dbService.addPrescription(prescription);
      await dbService.addMedicalRecordAction(
        title: 'Scan d\'ordonnance',
        description: 'Ordonnance sauvegardée depuis le scan',
        category: 'prescription',
        tags: ['prescription', 'scan'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ordonnance sauvegardée !'),
            backgroundColor: AppColors.success));
        // Naviguer vers l'onglet Ordonnances (index 2)
        final homeState = context.findAncestorStateOfType<HomeScreenState>();
        if (homeState != null) {
          homeState.switchToTab(2);
          Navigator.pop(context);
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur : $e'), backgroundColor: AppColors.error));
    }
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ScanButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: AppBorderRadius.lg,
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10)
          ],
          border: isPrimary ? null : Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: isPrimary ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SimpleMedCard extends StatelessWidget {
  final MedicineInfo med;
  const _SimpleMedCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppBorderRadius.md),
            child: const Icon(Icons.medication_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(med.dosage,
                    style: const TextStyle(
                        color: AppColors.grey500, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
