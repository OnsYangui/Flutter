import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consultation_model.dart';
import '../services/firestore_service.dart';
import '../services/realtime_db_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/theme_colors.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/consultation_preparation_card.dart';
import 'add_consultation_screen.dart';
import 'prepare_consultation_screen.dart';
import '../utils/app_localizations.dart';

const _primary = Color(0xFF00BCD4);

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: StreamBuilder<List<Consultation>>(
        stream: firestoreService.getConsultations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          final consultations = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      decoration: BoxDecoration(
                        color: context.headerBg,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
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
                                        AppLocalizations.of(context)?.manage ??
                                            'Gérez vos',
                                        style: TextStyle(
                                            fontSize: 15, color: context.textSecondary)),
                                    Text(
                                        AppLocalizations.of(context)
                                                ?.appointments ??
                                            'Consultations',
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary)),
                                  ]),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const AddConsultationScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                      color: _primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.inputBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: _Tab(
                                  label:
                                      AppLocalizations.of(context)?.upcoming ??
                                          'À venir',
                                  isActive: _selectedTab == 0,
                                  onTap: () => setState(() => _selectedTab = 0),
                                )),
                                Expanded(
                                    child: _Tab(
                                  label:
                                      AppLocalizations.of(context)?.history ??
                                          'Historique',
                                  isActive: _selectedTab == 1,
                                  onTap: () => setState(() => _selectedTab = 1),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _selectedTab == 0
                  ? _buildUpcomingSliver(consultations)
                  : _buildPastSliver(consultations),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingSliver(List<Consultation> consultations) {
    final now = DateTime.now();
    final upcoming = consultations
        .where((c) =>
            (c.status == ConsultationStatus.scheduled ||
                c.status == ConsultationStatus.confirmed) &&
            c.scheduledAt.isAfter(now))
        .toList();

    if (upcoming.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          title: AppLocalizations.of(context)?.noUpcomingAppointments ??
              'Aucun rendez-vous',
          message: AppLocalizations.of(context)?.scheduleCheckup ??
              'Planifiez votre prochain bilan',
          icon: Icons.calendar_today_outlined,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ConsultationPreparationCard(
              consultation: upcoming[index],
              onPrepare: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrepareConsultationScreen(
                          consultation: upcoming[index]))),
              onDelete: () => _deleteConsultation(upcoming[index]),
            ),
          ),
          childCount: upcoming.length,
        ),
      ),
    );
  }

  Widget _buildPastSliver(List<Consultation> consultations) {
    final now = DateTime.now();
    final past = consultations
        .where((c) =>
            c.status == ConsultationStatus.completed ||
            c.status == ConsultationStatus.cancelled ||
            c.status == ConsultationStatus.missed ||
            (c.scheduledAt.isBefore(now) &&
                c.status == ConsultationStatus.scheduled))
        .toList();

    if (past.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          title: AppLocalizations.of(context)?.noHistory ?? 'Aucun historique',
          message: AppLocalizations.of(context)?.pastConsultationsAppearHere ??
              'Vos consultations passées apparaîtront ici',
          icon: Icons.history_outlined,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PastCard(consultation: past[index]),
          ),
          childCount: past.length,
        ),
      ),
    );
  }

  void _deleteConsultation(Consultation consultation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Supprimer cette consultation ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF9E9BB4)))),
          TextButton(
            onPressed: () async {
              final firestore =
                  Provider.of<FirestoreService>(context, listen: false);
              final rt = Provider.of<RealtimeDbService>(context, listen: false);
              await firestore.deleteConsultation(consultation.id);
              await rt.deleteConsultation(consultation.id);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Color(0xFFFF5A7D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: _primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? _primary : const Color(0xFF9E9BB4),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _PastCard extends StatelessWidget {
  final Consultation consultation;
  const _PastCard({required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: _primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(consultation.doctorName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E))),
              Text(Helpers.formatDateTime(consultation.scheduledAt),
                  style: const TextStyle(color: Color(0xFF9E9BB4), fontSize: 12)),
              if (consultation.diagnosis != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('Diagnostic: ${consultation.diagnosis}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF9E9BB4))),
                ),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9E9BB4)),
        ],
      ),
    );
  }
}
