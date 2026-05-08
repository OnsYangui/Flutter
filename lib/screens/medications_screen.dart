import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../services/firestore_service.dart';
import '../services/realtime_db_service.dart';
import '../services/notification_service.dart';
import '../utils/theme_colors.dart';
import '../widgets/medication_card.dart';
import '../widgets/empty_state.dart';
import 'add_medication_screen.dart';
import 'scan_barcode_screen.dart';
import '../utils/app_localizations.dart';

const _primary = Color(0xFF00BCD4);

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
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
        child: StreamBuilder<List<Medication>>(
          stream: Provider.of<FirestoreService>(context).getMedications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _primary));
            }

            final medications = snapshot.data!;
            var filtered = medications;
            if (_filter == 'active')
              filtered = medications.where((m) => m.isActive).toList();
            else if (_filter == 'completed')
              filtered = medications.where((m) => !m.isActive).toList();

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
                                        AppLocalizations.of(context)?.your ??
                                            'Vos',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: context.textSecondary)),
                                    Text(
                                        AppLocalizations.of(context)
                                            ?.medications ??
                                            'Médicaments',
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _CircleBtn(
                                        icon: Icons.qr_code_scanner_rounded,
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                const ScanBarcodeScreen()))),
                                    const SizedBox(width: 10),
                                    _CircleBtn(
                                        icon: Icons.add_rounded,
                                        filled: true,
                                        onTap: () => _addMedication()),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                  color: context.inputBg,
                                  borderRadius: BorderRadius.circular(16)),
                              child: TextField(
                                style: TextStyle(color: context.textPrimary),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)
                                      ?.searchMedication ??
                                      'Rechercher...',
                                  hintStyle: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 14),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: context.textSecondary, size: 20),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                      label: AppLocalizations.of(context)
                                          ?.all ??
                                          'Tous',
                                      isActive: _filter == 'all',
                                      onTap: () =>
                                          setState(() => _filter = 'all')),
                                  _FilterChip(
                                      label: AppLocalizations.of(context)
                                          ?.active ??
                                          'Actifs',
                                      isActive: _filter == 'active',
                                      onTap: () =>
                                          setState(() => _filter = 'active')),
                                  _FilterChip(
                                      label: AppLocalizations.of(context)
                                          ?.completed ??
                                          'Terminés',
                                      isActive: _filter == 'completed',
                                      onTap: () => setState(
                                              () => _filter = 'completed')),
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
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      title: AppLocalizations.of(context)?.noMedications ??
                          'Aucun médicament',
                      message:
                      AppLocalizations.of(context)?.addFirstMedication ??
                          'Ajoutez votre premier médicament',
                      icon: Icons.medication_outlined,
                      onAction: () => _addMedication(),
                      actionText:
                      AppLocalizations.of(context)?.add ?? 'Ajouter',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: MedicationCard(
                            medication: filtered[index],
                            onTap: () => _editMedication(filtered[index]),
                            onTake: () => _markAsTaken(filtered[index]),
                            onDelete: () => _deleteMedication(filtered[index]),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ Passe onSaved pour revenir sur MedicationsScreen après sauvegarde
  void _addMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicationScreen(),
      ),
    );
  }

  void _editMedication(Medication med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationScreen(
          initialMedication: med,
        ),
      ),
    );
  }

  void _markAsTaken(Medication med) async {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final rt = Provider.of<RealtimeDbService>(context, listen: false);
    await firestore.markMedicationAsTaken(med.id, DateTime.now());
    await rt.markMedicationAsTaken(med.id, DateTime.now());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Médicament marqué comme pris'),
            backgroundColor: Color(0xFF00B4A6)),
      );
    }
  }

  void _deleteMedication(Medication med) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final rt = Provider.of<RealtimeDbService>(context, listen: false);
    // ✅ Capturer le contexte parent avant d'ouvrir le dialog
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Supprimer ${med.name} ?'),
        actions: [
          TextButton(
            // ✅ Ferme uniquement le dialog
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF9E9BB4))),
          ),
          TextButton(
            onPressed: () async {
              try {
                await firestore.deleteMedication(med.id);
                await rt.deleteMedication(med.id);
                await NotificationService()
                    .cancelMedicationReminders(med.id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Médicament supprimé'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Color(0xFFFF5A7D),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _CircleBtn(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: filled ? _primary : context.inputBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: filled ? Colors.white : context.textPrimary, size: 22),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? _primary : context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isActive ? _primary : context.borderColor),
          boxShadow: isActive
              ? [
            BoxShadow(
                color: _primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : context.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}