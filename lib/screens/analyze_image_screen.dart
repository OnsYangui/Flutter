import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ml_kit_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class AnalyzeImageScreen extends StatefulWidget {
  const AnalyzeImageScreen({super.key});

  @override
  State<AnalyzeImageScreen> createState() => _AnalyzeImageScreenState();
}

class _AnalyzeImageScreenState extends State<AnalyzeImageScreen> {
  final MLKitService _mlKit = MLKitService();
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  XFile? _selectedImage;
  List<String>? _labels;
  Map<String, bool>? _medicalKeywords;

  Future<void> _pickImage(ImageSource source) async {
    final feedback = FeedbackService();
    await feedback.vibrate();

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
        _selectedImage = image;
        _labels = null;
        _medicalKeywords = null;
      });

      try {
        final labels = await _mlKit.analyzeMedicalImage(image);
        final keywords = await _mlKit.checkMedicalKeywords(labels.join(' '));

        setState(() {
          _labels = labels;
          _medicalKeywords = keywords;
          _isAnalyzing = false;
        });

        await feedback.vibrateSuccess();
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
        });

        await feedback.vibrateError();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyser une image'),
        centerTitle: true,
      ),
      body: _isAnalyzing
          ? const LoadingIndicator(message: 'Analyse de l\'image en cours...')
          : _selectedImage == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_search,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Analysez une image médicale',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'L\'application identifiera automatiquement\nles objets et éléments dans l\'image',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Appareil photo'),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          FloatingActionButton.extended(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galerie'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(_selectedImage!.path),
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_labels != null) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Éléments détectés',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _labels!.map((label) {
                                    final isMedical =
                                        _medicalKeywords?.containsKey(
                                                label.toLowerCase()) ??
                                            false;
                                    return Chip(
                                      label: Text(label),
                                      backgroundColor: isMedical
                                          ? AppColors.primary.withOpacity(0.2)
                                          : Colors.grey.shade200,
                                      side: BorderSide.none,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_medicalKeywords != null) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.health_and_safety,
                                          color: AppColors.primary),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Text(
                                        'Alertes médicales',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ..._medicalKeywords!.entries.map((entry) {
                                    if (entry.value) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning,
                                                color: AppColors.error,
                                                size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }).toList(),
                                  if (!_medicalKeywords!.values.any((v) => v))
                                    const Text(
                                      'Aucune alerte médicale détectée',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      CustomButton(
                        text: 'Analyser une autre image',
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _labels = null;
                            _medicalKeywords = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
