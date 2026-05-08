import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/realtime_db_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/medication_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../utils/validators.dart';
import '../models/medicine_info_model.dart';
import 'home_screen.dart';
import 'medications_screen.dart';

class AddMedicationScreen extends StatefulWidget {
  final MedicineInfo? initialMedicineInfo;
  final Medication? initialMedication;
  const AddMedicationScreen(
      {super.key, this.initialMedicineInfo, this.initialMedication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  MedicationType _selectedType = MedicationType.pill;
  String _selectedFrequency = AppConstants.frequencies.first;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  int _durationDays = 30;
  DateTime _startDate = DateTime.now();
  bool _takeWithFood = false;
  bool _takeBeforeMeal = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMedicineInfo != null) {
      _nameController.text = widget.initialMedicineInfo!.name;
      _dosageController.text = widget.initialMedicineInfo!.dosage;
      if (widget.initialMedicineInfo!.indications.isNotEmpty) {
        _notesController.text =
            widget.initialMedicineInfo!.indications.join(', ');
      }
    } else if (widget.initialMedication != null) {
      final med = widget.initialMedication!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _notesController.text = med.notes ?? '';
      _selectedType = med.type;
      _selectedFrequency = med.frequency;
      _selectedTimes = med.times
          .map((dt) => TimeOfDay(hour: dt.hour, minute: dt.minute))
          .toList();
      _durationDays = med.durationDays;
      _startDate = med.startDate;
      _takeWithFood = med.takeWithFood ?? false;
      _takeBeforeMeal = med.takeBeforeMeal ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTimes.add(time);
        _selectedTimes.sort((a, b) => a.hour.compareTo(b.hour));
      });
    }
  }

  void _removeTime(TimeOfDay time) {
    setState(() {
      _selectedTimes.remove(time);
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final realtimeDbService =
        Provider.of<RealtimeDbService>(context, listen: false);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.initialMedication != null
                      ? 'Modifier le médicament'
                      : 'Ajouter un médicament',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informations générales'),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom du médicament',
                    hint: 'ex: Paracétamol',
                    icon: Icons.medication_outlined,
                    validator: (value) =>
                        value!.isEmpty ? 'Le nom est obligatoire' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTypeDropdownField()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _dosageController,
                          label: 'Dosage',
                          hint: 'e.g. 500mg',
                          icon: Icons.science_outlined,
                          validator: Validators.validateDosage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Planification'),
                  _buildDropdownField<String>(
                    label: 'Fréquence',
                    value: _selectedFrequency,
                    items: AppConstants.frequencies.map((freq) {
                      return DropdownMenuItem(value: freq, child: Text(freq));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedFrequency = val!),
                  ),
                  const SizedBox(height: 20),
                  const Text('Heures de prise',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.grey700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._selectedTimes.map((time) => _TimeChip(
                            time: time,
                            onDelete: () => _removeTime(time),
                          )),
                      _AddButton(label: 'Ajouter heure', onTap: _selectTime),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Durée et début'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDropdownField<int>(
                          label: 'Durée',
                          value: _durationDays,
                          items: [7, 14, 30, 60, 90, 180, 365].map((days) {
                            return DropdownMenuItem(
                                value: days, child: Text('$days jours'));
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _durationDays = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'Date de début',
                          value: _startDate,
                          onTap: _selectStartDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Instructions'),
                  _buildSwitchTile('Prendre avec les repas', _takeWithFood,
                      (val) => setState(() => _takeWithFood = val)),
                  _buildSwitchTile('Prendre avant le repas', _takeBeforeMeal,
                      (val) => setState(() => _takeBeforeMeal = val)),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes supplémentaires',
                    hint: 'Instructions particulières...',
                    icon: Icons.note_alt_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () =>
                        _handleSave(firestoreService, realtimeDbService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.lg),
                      elevation: 0,
                    ),
                    child: Text(widget.initialMedication != null
                        ? 'Enregistrer les modifications'
                        : 'Ajouter le médicament'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<MedicationType>(
          value: _selectedType,
          isExpanded: true,
          items: MedicationType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      type.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          isExpanded: true,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: const BorderSide(color: AppColors.grey100),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.grey700)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppBorderRadius.md,
              border: Border.all(color: AppColors.grey100),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.grey400),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Helpers.formatDate(value),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: AppColors.grey100),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _handleSave(FirestoreService firestoreService,
      RealtimeDbService realtimeDbService) async {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget.initialMedication?.id ?? Helpers.generateId(),
        name: _nameController.text,
        dosage: _dosageController.text,
        unit: _dosageController.text.split(' ').last,
        type: _selectedType,
        frequency: _selectedFrequency,
        times: _selectedTimes
            .map((t) => DateTime(
                  _startDate.year,
                  _startDate.month,
                  _startDate.day,
                  t.hour,
                  t.minute,
                ))
            .toList(),
        durationDays: _durationDays,
        startDate: _startDate,
        endDate: _startDate.add(Duration(days: _durationDays)),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        prescriptionId: widget.initialMedication?.prescriptionId ?? '',
        takeWithFood: _takeWithFood,
        takeBeforeMeal: _takeBeforeMeal,
        createdAt: widget.initialMedication?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        takenHistory: widget.initialMedication?.takenHistory ?? [],
      );

      if (widget.initialMedication != null) {
        await firestoreService.updateMedication(medication);
        await realtimeDbService.updateMedication(medication);
        await NotificationService().cancelMedicationReminders(medication.id);
        await NotificationService().scheduleMedicationReminder(medication);
      } else {
        await firestoreService.addMedication(medication);
        await realtimeDbService.addMedication(medication);
        await NotificationService().scheduleMedicationReminder(medication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialMedication != null
                ? 'Médicament mis à jour'
                : 'Médicament ajouté'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          final homeState =
              context.findAncestorStateOfType<HomeScreenState>();
          if (homeState != null) {
            homeState.switchToTab(1);
            Navigator.pop(context);
          } else {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }
}

// ─── Widgets privés ───────────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onDelete;
  const _TimeChip({required this.time, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: AppBorderRadius.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time.format(context),
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColors.primary, style: BorderStyle.solid),
          borderRadius: AppBorderRadius.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
