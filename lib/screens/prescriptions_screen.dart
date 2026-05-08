import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prescription_model.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../widgets/prescription_card.dart';
import '../widgets/empty_state.dart';
import 'scan_prescription_screen.dart';

const _primary = Color(0xFF00BCD4);

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: StreamBuilder<List<Prescription>>(
        stream: Provider.of<FirestoreService>(context).getPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          final prescriptions = snapshot.data ?? [];

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vos',
                                  style: TextStyle(
                                      fontSize: 15, color: context.textSecondary)),
                              Text('Ordonnances',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ScanPrescriptionScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: _primary, shape: BoxShape.circle),
                              child: const Icon(Icons.qr_code_scanner_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (prescriptions.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    title: 'Aucune ordonnance',
                    message: 'Scannez une ordonnance pour commencer',
                    icon: Icons.description_outlined,
                    onAction: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScanPrescriptionScreen()));
                    },
                    actionText: 'Scanner',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: PrescriptionCard(
                          prescription: prescriptions[index],
                          onTap: () {},
                          onDelete: () {},
                        ),
                      ),
                      childCount: prescriptions.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}
