import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vital_sign_model.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';
import '../utils/theme_colors.dart';
import '../widgets/vital_chart.dart';
import 'add_vital_screen.dart';
import '../utils/app_localizations.dart';

const _primary = Color(0xFF00BCD4);

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  VitalSignType _selectedType = VitalSignType.bloodGlucose;

  Color _typeColor(VitalSignType t) {
    switch (t) {
      case VitalSignType.bloodGlucose:
        return const Color(0xFFFF5A7D);
      case VitalSignType.bloodPressure:
        return const Color(0xFFFF7F50);
      case VitalSignType.weight:
        return const Color(0xFF00B4A6);
      case VitalSignType.temperature:
        return const Color(0xFFFFB347);
      default:
        return _primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: StreamBuilder<List<VitalSign>>(
        stream: Provider.of<FirestoreService>(context).getVitalSigns(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          final vitalSigns = snapshot.data!;
          final filteredForChart =
              vitalSigns.where((v) => v.type == _selectedType).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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
                                      AppLocalizations.of(context)?.health ??
                                          'Santé',
                                      style: TextStyle(
                                          fontSize: 15, color: context.textSecondary)),
                                  Text(
                                      AppLocalizations.of(context)
                                              ?.vitalSigns ??
                                          'Constantes vitales',
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
                                          builder: (_) => AddVitalScreen(
                                              type: _selectedType,
                                              onSaved: () => Navigator.pop(context))));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: _primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Type selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: VitalSignType.values.map((type) {
                                final isSelected = _selectedType == type;
                                final color = _typeColor(type);
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedType = type),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: isSelected ? color : context.cardBg,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: isSelected
                                              ? color
                                              : context.borderColor),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                  color: color.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2))
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(type.icon,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : context.textSecondary),
                                        const SizedBox(width: 6),
                                        Text(
                                          type.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : context.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Chart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: filteredForChart.isEmpty
                          ? Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: _primary.withOpacity(0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_selectedType.icon,
                                          size: 40,
                                          color: const Color(0xFFE0DFF0)),
                                      const SizedBox(height: 8),
                                      Text(
                                          AppLocalizations.of(context)
                                                  ?.noData ??
                                              'Aucune donnée',
                                           style:
                                               const TextStyle(color: Color(0xFF9E9BB4))),
                                    ]),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: VitalChart(
                                  vitals: filteredForChart,
                                  type: _selectedType),
                            ),
                    ),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        AppLocalizations.of(context)?.recentMeasurements ??
                            'Mesures récentes',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              _buildRecentListSliver(vitalSigns),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentListSliver(List<VitalSign> vitalSigns) {
    final filtered =
        vitalSigns.where((v) => v.type == _selectedType).take(10).toList();
    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)?.noData ??
                  'Aucune mesure enregistrée',
              style: const TextStyle(color: Color(0xFF9E9BB4)),
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _VitalCard(vital: filtered[index], type: _selectedType),
          childCount: filtered.length,
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final VitalSign vital;
  final VitalSignType type;
  const _VitalCard({required this.vital, required this.type});

  @override
  Widget build(BuildContext context) {
    final isOk = vital.isInNormalRange;
    final statusColor =
        isOk ? const Color(0xFF00B4A6) : const Color(0xFFFF5A7D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(type.icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${vital.value} ${type.unit}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E))),
              Text(Helpers.formatDateTime(vital.measuredAt),
                  style: const TextStyle(color: Color(0xFF9E9BB4), fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(vital.statusText,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
