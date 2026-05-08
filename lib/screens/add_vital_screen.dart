import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/realtime_db_service.dart';
import '../models/vital_sign_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class AddVitalScreen extends StatefulWidget {
  final VitalSignType type;
  final VoidCallback? onSaved;

  const AddVitalScreen({super.key, required this.type, this.onSaved});

  @override
  State<AddVitalScreen> createState() => _AddVitalScreenState();
}

class _AddVitalScreenState extends State<AddVitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glycemiaController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _measuredAt = DateTime.now();
  String? _mealContext;

  @override
  void dispose() {
    _glycemiaController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_measuredAt),
      );
      if (time != null) {
        setState(() {
          _measuredAt =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final realtimeDbService =
        Provider.of<RealtimeDbService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter ${widget.type.label}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildValueField(),
              const SizedBox(height: AppSpacing.md),

              // Contexte (pour glycémie)
              if (widget.type == VitalSignType.bloodGlucose) ...[
                DropdownButtonFormField<String>(
                  initialValue: _mealContext,
                  decoration: const InputDecoration(
                    labelText: 'Contexte du repas',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'À jeun',
                    'Avant repas',
                    'Après repas',
                    'Au coucher',
                  ].map((context) {
                    return DropdownMenuItem(
                        value: context, child: Text(context));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _mealContext = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Date et heure
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(Helpers.formatDateTime(_measuredAt)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              CustomButton(
                text: 'Enregistrer',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic value;

                    switch (widget.type) {
                      case VitalSignType.bloodGlucose:
                        value = double.parse(_glycemiaController.text);
                        break;
                      case VitalSignType.bloodPressure:
                        value =
                            '${_systolicController.text}/${_diastolicController.text}';
                        break;
                      case VitalSignType.heartRate:
                        value = int.parse(_heartRateController.text);
                        break;
                      case VitalSignType.weight:
                        value = double.parse(_weightController.text);
                        break;
                      case VitalSignType.temperature:
                        value = double.parse(_temperatureController.text);
                        break;
                      case VitalSignType.oxygenSaturation:
                        value = int.parse(_oxygenController.text);
                        break;
                      default:
                        value = 0;
                    }

                    final vitalSign = VitalSign(
                      id: Helpers.generateId(),
                      type: widget.type,
                      value: value,
                      measuredAt: _measuredAt,
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                      metadata: _mealContext != null
                          ? {'mealContext': _mealContext!}
                          : null,
                      createdAt: DateTime.now(),
                    );

                    try {
                      await firestoreService.addVitalSign(vitalSign);
                      await realtimeDbService.addVitalSign(vitalSign);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Constante enregistrée'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        if (widget.onSaved != null) {
                          widget.onSaved!();
                        } else {
                          // Force return to VitalSigns tab (index 3)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(initialTab: 3),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueField() {
    switch (widget.type) {
      case VitalSignType.bloodGlucose:
        return TextFormField(
          controller: _glycemiaController,
          decoration: const InputDecoration(
            labelText: 'Glycémie (mg/dL)',
            prefixIcon: Icon(Icons.bloodtype),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: Validators.validateGlycemia,
        );

      case VitalSignType.bloodPressure:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _systolicController,
                decoration: const InputDecoration(
                  labelText: 'Systolique',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text('/'),
            ),
            Expanded(
              child: TextFormField(
                controller: _diastolicController,
                decoration: const InputDecoration(
                  labelText: 'Diastolique',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        );

      case VitalSignType.heartRate:
        return TextFormField(
          controller: _heartRateController,
          decoration: const InputDecoration(
            labelText: 'Fréquence cardiaque (bpm)',
            prefixIcon: Icon(Icons.favorite),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer une valeur';
            }
            return null;
          },
        );

      case VitalSignType.weight:
        return TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Poids (kg)',
            prefixIcon: Icon(Icons.monitor_weight),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: Validators.validateWeight,
        );

      case VitalSignType.temperature:
        return TextFormField(
          controller: _temperatureController,
          decoration: const InputDecoration(
            labelText: 'Température (°C)',
            prefixIcon: Icon(Icons.thermostat),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: Validators.validateTemperature,
        );

      case VitalSignType.oxygenSaturation:
        return TextFormField(
          controller: _oxygenController,
          decoration: const InputDecoration(
            labelText: 'Saturation O2 (%)',
            prefixIcon: Icon(Icons.air),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: Validators.validateOxygenSaturation,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
