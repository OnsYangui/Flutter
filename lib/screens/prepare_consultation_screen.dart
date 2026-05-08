import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/realtime_db_service.dart';
import '../models/consultation_model.dart';
import '../models/vital_sign_model.dart';
import '../models/medication_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/vital_chart.dart';

class PrepareConsultationScreen extends StatefulWidget {
  final Consultation consultation;

  const PrepareConsultationScreen({
    super.key,
    required this.consultation,
  });

  @override
  State<PrepareConsultationScreen> createState() =>
      _PrepareConsultationScreenState();
}

class _PrepareConsultationScreenState extends State<PrepareConsultationScreen> {
  final TextEditingController _newSymptomController = TextEditingController();
  final TextEditingController _newQuestionController = TextEditingController();

  List<String> _symptoms = [];
  List<String> _questions = [];

  @override
  void initState() {
    super.initState();
    _symptoms = List.from(widget.consultation.symptoms);
    _questions = List.from(widget.consultation.questions);
  }

  void _addSymptom() {
    if (_newSymptomController.text.isNotEmpty) {
      setState(() {
        _symptoms.add(_newSymptomController.text);
        _newSymptomController.clear();
      });
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  void _addQuestion() {
    if (_newQuestionController.text.isNotEmpty) {
      setState(() {
        _questions.add(_newQuestionController.text);
        _newQuestionController.clear();
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _savePreparation() async {
    final updatedConsultation = widget.consultation.copyWith(
      symptoms: _symptoms,
      questions: _questions,
      updatedAt: DateTime.now(),
    );

    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final realtimeDbService =
        Provider.of<RealtimeDbService>(context, listen: false);

    await firestoreService.updateConsultation(updatedConsultation);
    await realtimeDbService.updateConsultation(updatedConsultation);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préparation sauvegardée'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportReport() async {
    // TODO: Export PDF with DataService data
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité à venir'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préparer ma consultation'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportReport,
            tooltip: 'Exporter en PDF',
          ),
        ],
      ),
      body: StreamBuilder<List<VitalSign>>(
        stream: firestoreService.getVitalSigns(),
        builder: (context, vitalSnapshot) {
          return StreamBuilder<List<Medication>>(
            stream: firestoreService.getMedications(),
            builder: (context, medSnapshot) {
              if (vitalSnapshot.connectionState == ConnectionState.waiting ||
                  medSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final vitals = vitalSnapshot.data ?? [];
              final medications = medSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.medical_services,
                                    color: AppColors.primary),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  widget.consultation.doctorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: AppSpacing.xs),
                                Text(Helpers.formatDateTime(
                                    widget.consultation.scheduledAt)),
                              ],
                            ),
                            if (widget.consultation.doctorSpecialty !=
                                null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  const Icon(Icons.science,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(widget.consultation.doctorSpecialty!),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '📊 Dernières constantes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    vitals.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Text('Aucune constante disponible'),
                            ),
                          )
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: vitals.take(5).map((v) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                        '${v.type.label}: ${v.value} ${v.type.unit} - ${Helpers.formatDate(v.measuredAt)}'),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '💊 Médicaments actuels',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    medications.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Text('Aucun médicament actif'),
                            ),
                          )
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: medications.take(5).map((m) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text('${m.name} - ${m.dosage}'),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '🤒 Symptômes actuels',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newSymptomController,
                            decoration: const InputDecoration(
                              hintText: 'Ajouter un symptôme',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary),
                          onPressed: _addSymptom,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: _symptoms.asMap().entries.map((entry) {
                        final index = entry.key;
                        final symptom = entry.value;
                        return Chip(
                          label: Text(symptom),
                          onDeleted: () => _removeSymptom(index),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '❓ Questions pour le médecin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newQuestionController,
                            decoration: const InputDecoration(
                              hintText: 'Ajouter une question',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary),
                          onPressed: _addQuestion,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: _questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return Chip(
                          label: Text(question),
                          onDeleted: () => _removeQuestion(index),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _symptoms =
                                    List.from(widget.consultation.symptoms);
                                _questions =
                                    List.from(widget.consultation.questions);
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réinitialiser'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CustomButton(
                            text: 'Sauvegarder',
                            onPressed: _savePreparation,
                            icon: Icons.save,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      color: AppColors.info.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: AppColors.info),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Conseils pour votre consultation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text('• Arrivez 10 minutes en avance'),
                            Text('• Apportez votre dossier médical'),
                            Text('• Notez les réponses du médecin'),
                            Text('• Demandez un compte-rendu écrit'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
