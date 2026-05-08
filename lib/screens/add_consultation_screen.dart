import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/realtime_db_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/consultation_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class AddConsultationScreen extends StatefulWidget {
  const AddConsultationScreen({super.key});

  @override
  State<AddConsultationScreen> createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _doctorSpecialtyController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _doctorEmailController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  ConsultationType _selectedType = ConsultationType.inPerson;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 7));
  final List<String> _symptoms = [];
  final List<String> _questions = [];

  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _doctorNameController.dispose();
    _doctorSpecialtyController.dispose();
    _doctorPhoneController.dispose();
    _doctorEmailController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _symptomController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addSymptom() {
    if (_symptomController.text.isNotEmpty) {
      setState(() {
        _symptoms.add(_symptomController.text);
        _symptomController.clear();
      });
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  void _addQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _questions.add(_questionController.text);
        _questionController.clear();
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
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
                const Text(
                  'Prendre rendez-vous',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informations médecin'),
                  _buildTextField(
                    controller: _doctorNameController,
                    label: 'Nom du médecin',
                    hint: 'Dr. Jean Dupont',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value!.isEmpty ? 'Le nom est obligatoire' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _doctorSpecialtyController,
                    label: 'Spécialité',
                    hint: 'Cardiologue, Généraliste...',
                    icon: Icons.medical_services_outlined,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _doctorPhoneController,
                          label: 'Téléphone',
                          hint: '+216...',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _doctorEmailController,
                          label: 'Email',
                          hint: 'medecin@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => (val != null && val.isNotEmpty)
                              ? Validators.validateEmail(val)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Détails du rendez-vous'),
                  _buildDropdownField<ConsultationType>(
                    label: 'Type',
                    value: _selectedType,
                    items: ConsultationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              type == ConsultationType.inPerson
                                  ? Icons.location_on_outlined
                                  : type == ConsultationType.video
                                      ? Icons.videocam_outlined
                                      : Icons.phone_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(type.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePickerField(
                    label: 'Date et heure',
                    value: _selectedDateTime,
                    onTap: _selectDateTime,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedType == ConsultationType.inPerson)
                    _buildTextField(
                      controller: _locationController,
                      label: 'Lieu / Clinique',
                      hint: '123 Rue Médicale',
                      icon: Icons.map_outlined,
                    ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Symptômes et questions'),
                  _buildListInput(
                    controller: _symptomController,
                    label: 'Symptômes actuels',
                    hint: 'Ajouter un symptôme...',
                    items: _symptoms,
                    onAdd: _addSymptom,
                    onRemove: _removeSymptom,
                  ),
                  const SizedBox(height: 16),
                  _buildListInput(
                    controller: _questionController,
                    label: 'Questions pour le médecin',
                    hint: 'Poser une question...',
                    items: _questions,
                    onAdd: _addQuestion,
                    onRemove: _removeQuestion,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes supplémentaires',
                    hint: 'Contexte de votre visite...',
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
                    child: const Text('Enregistrer le rendez-vous'),
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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

  Widget _buildDateTimePickerField({
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppBorderRadius.md,
              border: Border.all(color: AppColors.grey100),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: AppColors.grey400),
                const SizedBox(width: 12),
                Text(Helpers.formatDateTime(value)),
                const Spacer(),
                const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<String> items,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
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
            ),
            const SizedBox(width: 12),
            _AddIconButton(onTap: onAdd),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .asMap()
                .entries
                .map((e) =>
                    _ItemChip(label: e.value, onRemove: () => onRemove(e.key)))
                .toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _handleSave(FirestoreService firestoreService,
      RealtimeDbService realtimeDbService) async {
    if (_formKey.currentState!.validate()) {
      final consultation = Consultation(
        id: Helpers.generateId(),
        doctorName: _doctorNameController.text,
        doctorSpecialty: _doctorSpecialtyController.text.isEmpty
            ? null
            : _doctorSpecialtyController.text,
        doctorPhone: _doctorPhoneController.text.isEmpty
            ? null
            : _doctorPhoneController.text,
        doctorEmail: _doctorEmailController.text.isEmpty
            ? null
            : _doctorEmailController.text,
        scheduledAt: _selectedDateTime,
        type: _selectedType,
        status: ConsultationStatus.scheduled,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        symptoms: _symptoms,
        questions: _questions,
        doctorNotes:
            _notesController.text.isEmpty ? null : _notesController.text,
        prescriptions: const [],
        exams: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.addConsultation(consultation);
      await realtimeDbService.addConsultation(consultation);
      await NotificationService().scheduleConsultationReminder(consultation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous enregistré !'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          final homeState =
              context.findAncestorStateOfType<HomeScreenState>();
          if (homeState != null) {
            homeState.switchToTab(4);
            Navigator.pop(context);
          } else {
            Navigator.pop(context, true);
          }
        }
      }
    }
  }
}

class _AddIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.md,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: AppBorderRadius.md),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ItemChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: AppBorderRadius.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(width: 8),
          InkWell(
              onTap: onRemove,
              child:
                  const Icon(Icons.close, size: 14, color: AppColors.primary)),
        ],
      ),
    );
  }
}
