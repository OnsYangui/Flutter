import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/medication_model.dart';
import '../models/consultation_model.dart';
import '../models/vital_sign_model.dart';
import '../models/prescription_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      backgroundColor: context.bgColor,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: StreamBuilder<List<Medication>>(
          stream: firestoreService.getMedications(),
          builder: (context, medSnapshot) {
            if (medSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: LoadingIndicator(message: 'Chargement...'));
            }
            return StreamBuilder<List<Consultation>>(
              stream: firestoreService.getConsultations(),
              builder: (context, consultSnapshot) {
                if (consultSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: LoadingIndicator(message: 'Chargement...'));
                }
                return StreamBuilder<List<VitalSign>>(
                  stream: firestoreService.getVitalSigns(),
                  builder: (context, vitalSnapshot) {
                    if (vitalSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: LoadingIndicator(message: 'Chargement...'));
                    }
                    return StreamBuilder<List<Prescription>>(
                      stream: firestoreService.getPrescriptions(),
                      builder: (context, prescSnapshot) {
                        if (prescSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child:
                                  LoadingIndicator(message: 'Chargement...'));
                        }

                        final medications = medSnapshot.data ?? [];
                        final consultations = consultSnapshot.data ?? [];
                        final vitals = vitalSnapshot.data ?? [];
                        final prescriptions = prescSnapshot.data ?? [];

                        final allItems = [
                          ...medications.map((m) => HistoryItem(
                                type: HistoryItemType.medication,
                                title: m.name,
                                subtitle: 'Médicament',
                                date: m.createdAt,
                                icon: Icons.medication,
                                color: AppColors.primary,
                              )),
                          ...consultations.map((c) => HistoryItem(
                                type: HistoryItemType.consultation,
                                title: c.doctorName,
                                subtitle: 'Rendez-vous',
                                date: c.scheduledAt,
                                icon: Icons.calendar_today,
                                color: AppColors.accent,
                              )),
                          ...vitals.map((v) => HistoryItem(
                                type: HistoryItemType.vitalSign,
                                title: v.type.label,
                                subtitle: 'Constante',
                                date: v.measuredAt,
                                icon: Icons.monitor_heart,
                                color: AppColors.success,
                              )),
                          ...prescriptions.map((p) => HistoryItem(
                                type: HistoryItemType.prescription,
                                title: 'Dr. ${p.doctorName}',
                                subtitle: 'Ordonnance',
                                date: p.createdAt,
                                icon: Icons.description,
                                color: Colors.green,
                              )),
                        ]..sort((a, b) => b.date.compareTo(a.date));

                        if (allItems.isEmpty) {
                          return const EmptyState(
                            title: 'Aucun historique',
                            message:
                                'Ajoutez des médicaments, rendez-vous ou constantes pour voir votre historique.',
                            icon: Icons.history,
                          );
                        }

                        return CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              expandedHeight: 120,
                              pinned: true,
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              flexibleSpace: FlexibleSpaceBar(
                                title: const Text('Historique',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                background: Container(
                                  color: AppColors.primary,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: -20,
                                        top: -20,
                                        child: Icon(Icons.history,
                                            size: 100,
                                            color: Colors.white
                                                .withValues(alpha: 0.1)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = allItems[index];
                                  return HistoryItemCard(item: item);
                                },
                                childCount: allItems.length,
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

enum HistoryItemType { medication, consultation, vitalSign, prescription }

class HistoryItem {
  final HistoryItemType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;

  HistoryItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });
}

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;

  const HistoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lg,
        side: BorderSide(color: item.color.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: AppBorderRadius.md,
          ),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle),
            Text(
              Helpers.formatDateTime(item.date),
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
