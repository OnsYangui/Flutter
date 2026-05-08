import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/hospital_model.dart';
import '../services/realtime_db_service.dart';
import '../utils/constants.dart';
import '../utils/theme_colors.dart';

class HospitalsDoctorsScreen extends StatefulWidget {
  const HospitalsDoctorsScreen({super.key});

  @override
  State<HospitalsDoctorsScreen> createState() => _HospitalsDoctorsScreenState();
}

class _HospitalsDoctorsScreenState extends State<HospitalsDoctorsScreen> {
  int _selectedTab = 0; // 0: Hospitals, 1: Doctors
  String? _selectedSpecialty;
  String? _selectedHospitalId;

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<RealtimeDbService>(context, listen: false);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00BCD4), Color(0xFFF0FAFB)],
                  stops: [0.0, 0.45],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trouver',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Text(
                            'Soins Médicaux',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      _HeaderIcon(
                        icon: Icons.add,
                        onTap: () => _showAddOptions(context, dbService),
                        color: AppColors.primary,
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppBorderRadius.lg,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un hôpital ou un médecin...',
                        prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _FilterPill(
                          label: 'Hôpitaux',
                          isActive: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterPill(
                          label: 'Médecins',
                          isActive: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _selectedTab == 0
              ? _buildHospitalsSliver(dbService)
              : _buildDoctorsSliver(dbService),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context, RealtimeDbService dbService) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.local_hospital, color: AppColors.primary),
                title: const Text('Ajouter une clinique / hôpital'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddHospitalDialog(context, dbService);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: const Text('Ajouter un médecin'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddDoctorDialog(context, dbService);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dataset),
                title: const Text('Ajouter des données d\'exemple'),
                onTap: () async {
                  Navigator.pop(context);
                  await dbService.addSampleData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Données d\'exemple ajoutées'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddHospitalDialog(
      BuildContext context, RealtimeDbService dbService) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String address = '';
    String phone = '';
    String email = '';
    bool isEmergency = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle Clinique / Hôpital'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Champ requis' : null,
                    onSaved: (val) => name = val!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    onSaved: (val) => address = val ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                    onSaved: (val) => phone = val ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => email = val ?? '',
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return CheckboxListTile(
                        title: const Text('Urgence 24h/24'),
                        value: isEmergency,
                        onChanged: (val) {
                          setStateSB(() {
                            isEmergency = val ?? false;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final hospital = Hospital(
                    id: '', // Will be generated by Firebase
                    name: name,
                    address: address,
                    phone: phone.isNotEmpty ? phone : null,
                    email: email.isNotEmpty ? email : null,
                    latitude: 0.0,
                    longitude: 0.0,
                    specialties: [],
                    isEmergency: isEmergency,
                  );
                  await dbService.addHospital(hospital);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Hôpital ajouté avec succès !')),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDoctorDialog(BuildContext context, RealtimeDbService dbService) {
    final formKey = GlobalKey<FormState>();
    String firstName = '';
    String lastName = '';
    String specialty = '';
    String phone = '';
    String email = '';
    String? hospitalId;
    String? hospitalName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau Médecin'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Prénom *'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Champ requis' : null,
                    onSaved: (val) => firstName = val!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Champ requis' : null,
                    onSaved: (val) => lastName = val!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Spécialité *'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Champ requis' : null,
                    onSaved: (val) => specialty = val!,
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<List<Hospital>>(
                    stream: dbService.getHospitals(),
                    builder: (context, snapshot) {
                      final hospitals = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        value: hospitalId,
                        decoration: const InputDecoration(
                            labelText: 'Hôpital / Clinique'),
                        items: hospitals.map((h) {
                          return DropdownMenuItem(
                            value: h.id,
                            child: Text(h.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          hospitalId = val;
                          if (val != null) {
                            hospitalName =
                                hospitals.firstWhere((h) => h.id == val).name;
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                    onSaved: (val) => phone = val ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => email = val ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final doctor = Doctor(
                    id: '', // Generated by Firebase
                    firstName: firstName,
                    lastName: lastName,
                    specialty: specialty,
                    hospitalId: hospitalId,
                    hospitalName: hospitalName,
                    phone: phone.isNotEmpty ? phone : null,
                    email: email.isNotEmpty ? email : null,
                    availableDays: [],
                  );
                  await dbService.addDoctor(doctor);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Médecin ajouté avec succès !')),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: AppBorderRadius.md,
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalsSliver(RealtimeDbService dbService) {
    return StreamBuilder<List<Hospital>>(
      stream: dbService.getHospitals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_hospital_outlined, size: 80, color: AppColors.grey300),
                  SizedBox(height: 20),
                  Text('Aucun hôpital trouvé', style: TextStyle(color: AppColors.grey500)),
                ],
              ),
            ),
          );
        }
        final hospitals = snapshot.data!;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final hospital = hospitals[index];
                return _HospitalCard(hospital: hospital, onPhone: _launchPhone, onEmail: _launchEmail, onUrl: _launchUrl);
              },
              childCount: hospitals.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorsSliver(RealtimeDbService dbService) {
    return StreamBuilder<List<Doctor>>(
      stream: dbService.getDoctors(
        specialty: _selectedSpecialty,
        hospitalId: _selectedHospitalId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: AppColors.grey300),
                  SizedBox(height: 20),
                  Text('Aucun médecin trouvé', style: TextStyle(color: AppColors.grey500)),
                ],
              ),
            ),
          );
        }
        final doctors = snapshot.data!;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final doctor = doctors[index];
                return _DoctorCard(doctor: doctor, onPhone: _launchPhone, onEmail: _launchEmail);
              },
              childCount: doctors.length,
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  String _translateDay(String day) {
    const days = {
      'Monday': 'Lundi',
      'Tuesday': 'Mardi',
      'Wednesday': 'Mercredi',
      'Thursday': 'Jeudi',
      'Friday': 'Vendredi',
      'Saturday': 'Samedi',
      'Sunday': 'Dimanche',
    };
    return days[day] ?? day;
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color ?? AppColors.white,
          shape: BoxShape.circle,
          boxShadow: color == null ? [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ] : null,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.black, size: 22),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: AppBorderRadius.md,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.grey200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.grey600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final Function(String) onPhone;
  final Function(String) onEmail;
  final Function(String) onUrl;

  const _HospitalCard({
    required this.hospital,
    required this.onPhone,
    required this.onEmail,
    required this.onUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppBorderRadius.lg,
                ),
                child: const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (hospital.isEmergency)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: AppBorderRadius.sm,
                        ),
                        child: const Text('24/7 Emergency', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hospital.address != null)
            _IconLabel(icon: Icons.location_on_outlined, label: hospital.address!),
          const SizedBox(height: 12),
          Row(
            children: [
              if (hospital.phone != null)
                Expanded(child: _ActionChip(icon: Icons.phone_outlined, label: 'Appeler', onTap: () => onPhone(hospital.phone!))),
              if (hospital.email != null) ...[
                const SizedBox(width: 8),
                Expanded(child: _ActionChip(icon: Icons.email_outlined, label: 'Email', onTap: () => onEmail(hospital.email!))),
              ],
              if (hospital.website != null) ...[
                const SizedBox(width: 8),
                Expanded(child: _ActionChip(icon: Icons.language_outlined, label: 'Site web', onTap: () => onUrl(hospital.website!))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Function(String) onPhone;
  final Function(String) onEmail;

  const _DoctorCard({
    required this.doctor,
    required this.onPhone,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  doctor.firstName[0].toUpperCase() + doctor.lastName[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (doctor.hospitalName != null)
            _IconLabel(icon: Icons.business_outlined, label: doctor.hospitalName!),
          const SizedBox(height: 12),
          Row(
            children: [
              if (doctor.phone != null)
                Expanded(child: _ActionChip(icon: Icons.phone_outlined, label: 'Call', onTap: () => onPhone(doctor.phone!))),
              if (doctor.email != null) ...[
                const SizedBox(width: 8),
                Expanded(child: _ActionChip(icon: Icons.email_outlined, label: 'Email', onTap: () => onEmail(doctor.email!))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.grey600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: AppBorderRadius.md,
          border: Border.all(color: AppColors.grey100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
