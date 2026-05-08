import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oz_medical/models/vital_sign_model.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/medication_model.dart';
import '../models/consultation_model.dart';
import '../models/prescription_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../widgets/medication_card.dart';
import '../widgets/empty_state.dart';
import 'profile_screen.dart';
import 'medications_screen.dart';
import 'scan_prescription_screen.dart';
import 'prescriptions_screen.dart';
import 'scan_barcode_screen.dart';
import 'analyze_image_screen.dart';
import 'vital_signs_screen.dart';
import 'consultations_screen.dart';
import 'hospitals_doctors_screen.dart';
import '../utils/app_localizations.dart';

// Design tokens matching the medical template (teal/cyan)
class _OzColors {
  static const primary = Color(0xFF00BCD4);
  static const primaryLight = Color(0xFF4DD0E1);
  static const primaryDark = Color(0xFF0097A7);
  static const bgLight = Color(0xFFF0FAFB);
  static const textDark = Color(0xFF1A1A2E);
  static const textMid = Color(0xFF9E9BB4);
  static const cardBg = Colors.white;
  static const coral = Color(0xFFFF7F50);
  static const rose = Color(0xFFFF5A7D);
  static const teal = Color(0xFF00B4A6);
  static const sky = Color(0xFF00B4D8);
  static const amber = Color(0xFFFFB347);
}

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = [
    const HomeContent(),
    const MedicationsScreen(),
    const PrescriptionsScreen(),
    const VitalSignsScreen(),
    const ConsultationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.headerBg,
          boxShadow: [
            BoxShadow(
              color: _OzColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: context.headerBg,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _OzColors.primary,
          unselectedItemColor: _OzColors.textMid,
          selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, size: 22),
              activeIcon: const Icon(Icons.home_rounded, size: 22),
              label: AppLocalizations.of(context)?.home ?? 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.medication_outlined, size: 22),
              activeIcon: const Icon(Icons.medication_rounded, size: 22),
              label: AppLocalizations.of(context)?.medications ?? 'Médicaments',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.description_outlined, size: 22),
              activeIcon: const Icon(Icons.description_rounded, size: 22),
              label: 'Ordonnances',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monitor_heart_outlined, size: 22),
              activeIcon: const Icon(Icons.monitor_heart_rounded, size: 22),
              label: AppLocalizations.of(context)?.medicalInfo ?? 'Constantes',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined, size: 22),
              activeIcon: const Icon(Icons.calendar_today_rounded, size: 22),
              label:
              AppLocalizations.of(context)?.appointments ?? 'Rendez-vous',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded, size: 22),
              activeIcon: const Icon(Icons.person_rounded, size: 22),
              label: AppLocalizations.of(context)?.profile ?? 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ScanPrescriptionScreen())),
        backgroundColor: _OzColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Scanner',
            style: TextStyle(fontWeight: FontWeight.w600)),
      )
          : null,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.headerGradient,
            stops: const [0.0, 0.45],
          ),
        ),
        child: StreamBuilder(
          stream: firestoreService.getMedications(),
          builder: (context, medsSnapshot) {
            return StreamBuilder(
              stream: firestoreService.getConsultations(),
              builder: (context, consultsSnapshot) {
                return StreamBuilder(
                  stream: firestoreService.getVitalSigns(),
                  builder: (context, vitalsSnapshot) {
                    return StreamBuilder(
                      stream: firestoreService.getPrescriptions(),
                      builder: (context, prescriptionsSnapshot) {
                        if (!medsSnapshot.hasData ||
                            !consultsSnapshot.hasData ||
                            !vitalsSnapshot.hasData ||
                            !prescriptionsSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: _OzColors.primary));
                        }

                        final medications = medsSnapshot.data!;
                        final consultations = consultsSnapshot.data!;
                        final vitals = vitalsSnapshot.data!;
                        final prescriptions = prescriptionsSnapshot.data!;
                        final todayMeds = medications
                            .where((m) => m.shouldTakeToday)
                            .toList();
                        final historyCount = medications.length +
                            consultations.length +
                            vitals.length +
                            prescriptions.length;

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Header ──────────────────────────────────────────
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 60, 24, 28),
                                    decoration: BoxDecoration(
                                      color: context.headerBg,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(28),
                                        bottomRight: Radius.circular(28),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${AppLocalizations.of(context)?.hello ?? 'Bonjour'},',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: _OzColors.textMid),
                                                ),
                                                Text(
                                                  '${user?.fullName ?? 'Utilisateur'}!',
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color:
                                                      _OzColors.textDark),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                _CircleIconBtn(
                                                  icon: Icons
                                                      .notifications_none_rounded,
                                                  onTap: () {},
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color:
                                                        _OzColors.primary,
                                                        width: 2),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor: _OzColors
                                                        .primary
                                                        .withOpacity(0.1),
                                                    backgroundImage: user
                                                        ?.profileImageUrl !=
                                                        null
                                                        ? FileImage(File(user!
                                                        .profileImageUrl!))
                                                        : null,
                                                    child: user?.profileImageUrl ==
                                                        null
                                                        ? const Icon(
                                                        Icons
                                                            .person_rounded,
                                                        color: _OzColors
                                                            .primary,
                                                        size: 22)
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: _OzColors.bgLight,
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                              AppLocalizations.of(context)
                                                  ?.searchPlaceholder ??
                                                  'Rechercher...',
                                              hintStyle: const TextStyle(
                                                  color: _OzColors.textMid,
                                                  fontSize: 14),
                                              prefixIcon: const Icon(
                                                  Icons.search_rounded,
                                                  color: _OzColors.textMid,
                                                  size: 20),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              fillColor: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // ── Stats Grid ──────────────────────────────────────
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: _StatsGrid(
                                      medCount: medications.length,
                                      consultCount: consultations.length,
                                      vitalsCount: vitals.length,
                                      historyCount: historyCount,
                                    ),
                                  ),

                                  // ── Upcoming Appointment ────────────────────────────
                                  if (consultations.isNotEmpty) ...[
                                    const SizedBox(height: 28),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: _SectionHeader(
                                        title: 'Prochain Rendez-vous',
                                        onSeeAll: () {
                                          final s =
                                          context.findAncestorStateOfType<
                                              HomeScreenState>();
                                          s?.switchToTab(4);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: _AppointmentCard(
                                          consultation: consultations.first),
                                    ),
                                  ],

                                  // ── Vitals ──────────────────────────────────────────
                                  const SizedBox(height: 28),
                                  const Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 24),
                                    child: Text('Santé & Constantes',
                                        style: _sectionTitleStyle),
                                  ),
                                  const SizedBox(height: 14),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: QuickVitalsCard(vitals: vitals),
                                  ),

                                  // ── AI Grid ─────────────────────────────────────────
                                  const SizedBox(height: 28),
                                  const Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 24),
                                    child: Text('Assistant IA Médical',
                                        style: _sectionTitleStyle),
                                  ),
                                  const SizedBox(height: 14),
                                  const Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 24),
                                    child: MLKitFeaturesGrid(),
                                  ),

                                  // ── Today's Meds ─────────────────────────────────────
                                  const SizedBox(height: 28),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: _SectionHeader(
                                      title: 'Médicaments du jour',
                                      onSeeAll: () {
                                        final s =
                                        context.findAncestorStateOfType<
                                            HomeScreenState>();
                                        s?.switchToTab(1);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (todayMeds.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: EmptyState(
                                        title: AppLocalizations.of(context)
                                            ?.noMedicationsToday ??
                                            'Pas de médicaments aujourd\'hui',
                                        message: AppLocalizations.of(context)
                                            ?.everythingUpToDate ??
                                            'Tout est à jour !',
                                        icon:
                                        Icons.check_circle_outline_rounded,
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: Column(
                                        children: todayMeds
                                            .map((med) => Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 12),
                                          child: MedicationCard(
                                            medication: med,
                                            onTap: () {},
                                            onTake: () {},
                                            onDelete: () {},
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

const _sectionTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: _OzColors.textDark,
);

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: _sectionTitleStyle),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('Voir tout',
                style: TextStyle(
                    color: _OzColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
      ],
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            color: _OzColors.bgLight, shape: BoxShape.circle),
        child: Icon(icon, color: _OzColors.textDark, size: 22),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int medCount, consultCount, vitalsCount, historyCount;
  const _StatsGrid({
    required this.medCount,
    required this.consultCount,
    required this.vitalsCount,
    required this.historyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    icon: Icons.medication_rounded,
                    color: _OzColors.primary,
                    number: medCount.toString(),
                    label:
                    AppLocalizations.of(context)?.meds ?? 'Médicaments')),
            const SizedBox(width: 14),
            Expanded(
                child: _StatTile(
                    icon: Icons.calendar_today_rounded,
                    color: _OzColors.coral,
                    number: consultCount.toString(),
                    label: AppLocalizations.of(context)?.consults ??
                        'Consultations')),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _StatTile(
                    icon: Icons.favorite_rounded,
                    color: _OzColors.rose,
                    number: vitalsCount.toString(),
                    label:
                    AppLocalizations.of(context)?.vitals ?? 'Constantes')),
            const SizedBox(width: 14),
            Expanded(
                child: _StatTile(
                    icon: Icons.history_rounded,
                    color: _OzColors.teal,
                    number: historyCount.toString(),
                    label: AppLocalizations.of(context)?.historyTitle ??
                        'Historique')),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String number;
  final String label;
  const _StatTile(
      {required this.icon,
        required this.color,
        required this.number,
        required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(number,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _OzColors.textDark)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _OzColors.textMid,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Consultation consultation;
  const _AppointmentCard({required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_OzColors.primary, _OzColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _OzColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(consultation.doctorName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(consultation.doctorSpecialty ?? 'Généraliste',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                    ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.phone_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(Helpers.formatDate(consultation.scheduledAt),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.access_time_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(Helpers.formatTime(consultation.scheduledAt),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
    );
  }
}

class QuickVitalsCard extends StatelessWidget {
  final List<VitalSign> vitals;
  const QuickVitalsCard({super.key, required this.vitals});

  @override
  Widget build(BuildContext context) {
    final recentVitals = vitals.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _OzColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                  AppLocalizations.of(context)?.recentMeasurements ??
                      'Dernières mesures',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _OzColors.textDark)),
              const Icon(Icons.history_rounded,
                  size: 20, color: _OzColors.textMid),
            ]),
            const SizedBox(height: 16),
            if (recentVitals.isEmpty)
              Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        AppLocalizations.of(context)?.noData ?? 'Aucune mesure',
                        style: const TextStyle(
                            color: _OzColors.textMid,
                            fontStyle: FontStyle.italic)),
                  ))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...recentVitals.map((v) {
                      Color c = _OzColors.primary;
                      if (v.type == VitalSignType.bloodGlucose)
                        c = _OzColors.rose;
                      if (v.type == VitalSignType.bloodPressure)
                        c = _OzColors.coral;
                      if (v.type == VitalSignType.weight) c = _OzColors.teal;
                      if (v.type == VitalSignType.temperature)
                        c = _OzColors.amber;
                      String val = v.value.toString();
                      if (v.type == VitalSignType.bloodGlucose &&
                          v.value is num)
                        val =
                            Helpers.formatGlycemia((v.value as num).toDouble());
                      else if (v.type == VitalSignType.weight)
                        val = '${v.value} kg';
                      else if (v.type == VitalSignType.temperature)
                        val = '${v.value}°C';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _VitalItem(
                            icon: v.type.icon,
                            label: v.type.label,
                            value: val,
                            color: c),
                      );
                    }),
                    if (recentVitals.length < 3)
                      ...List.generate(
                          3 - recentVitals.length,
                              (_) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _VitalItem(
                                icon: Icons.add_circle_outline_rounded,
                                label: '---',
                                value: '--',
                                color: Color(0xFFE0DFF0)),
                          )),
                  ],
                ),
              ),
            const Divider(height: 24, color: Color(0xFFF0EFF8)),
            Center(
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VitalSignsScreen())),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Text(
                      AppLocalizations.of(context)?.seeAll ??
                          'Voir tout l\'historique',
                      style: const TextStyle(
                          color: _OzColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _VitalItem(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _OzColors.textDark)),
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: _OzColors.textMid,
              fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── FIXED: MLKitFeaturesGrid ─────────────────────────────────────────────────
class MLKitFeaturesGrid extends StatelessWidget {
  const MLKitFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.receipt_long_rounded,
        'label': AppLocalizations.of(context)?.scannerOrdonnance ??
            'Scanner ordonnance',
        'screen': const ScanPrescriptionScreen(),
        'color': _OzColors.primary
      },
      {
        'icon': Icons.qr_code_scanner_rounded,
        'label':
        AppLocalizations.of(context)?.scannerCodeBarres ?? 'Code-barres',
        'screen': const ScanBarcodeScreen(),
        'color': _OzColors.sky
      },
      {
        'icon': Icons.image_search_rounded,
        'label':
        AppLocalizations.of(context)?.analyserImage ?? 'Analyser image',
        'screen': const AnalyzeImageScreen(),
        'color': _OzColors.coral
      },
      {
        'icon': Icons.local_hospital_rounded,
        'label': AppLocalizations.of(context)?.hopitauxMedecins ??
            'Hôpitaux & Médecins',
        'screen': const HospitalsDoctorsScreen(),
        'color': _OzColors.rose
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.2, // FIX: was 1.5 — too wide/short, caused overflow
      children: features
          .map((f) => _FeatureTile(
        icon: f['icon'] as IconData,
        label: f['label'] as String,
        color: f['color'] as Color,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => f['screen'] as Widget)),
      ))
          .toList(),
    );
  }
}

// ── FIXED: _FeatureTile ───────────────────────────────────────────────────────
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FeatureTile(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        // FIX: reduced padding to give content more room
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // FIX: don't expand beyond content
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24), // FIX: 26 → 24
            ),
            const SizedBox(height: 8), // FIX: 10 → 8
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,              // FIX: 1 → 2, allows wrapping
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _OzColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}