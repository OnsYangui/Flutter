import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/vital_sign_model.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';

class VitalChart extends StatelessWidget {
  final List<VitalSign> vitals;
  final VitalSignType type;

  const VitalChart({
    super.key,
    required this.vitals,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (vitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, size: 48, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)?.noData ?? 'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type.icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  type.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${AppLocalizations.of(context)?.average ?? 'Average'}: ${_calculateAverage()} ${type.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 250,
              child: LineChart(
                _createChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createChartData() {
    final spots = <FlSpot>[];
    for (int i = 0; i < vitals.length; i++) {
      double value = 0;
      if (type == VitalSignType.bloodPressure && vitals[i].value is String) {
        final components = vitals[i].bloodPressureComponents;
        value = components?['systolic']?.toDouble() ?? 0;
      } else if (vitals[i].value is double) {
        value = vitals[i].value as double;
      } else if (vitals[i].value is int) {
        value = (vitals[i].value as int).toDouble();
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    final (minY, maxY) = _getYRange();

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
      minY: minY,
      maxY: maxY,
    );
  }

  (double, double) _getYRange() {
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var vital in vitals) {
      double value = 0;
      if (type == VitalSignType.bloodPressure && vital.value is String) {
        final components = vital.bloodPressureComponents;
        value = components?['systolic']?.toDouble() ?? 0;
      } else if (vital.value is double) {
        value = vital.value as double;
      } else if (vital.value is int) {
        value = (vital.value as int).toDouble();
      }

      if (value < minY) minY = value;
      if (value > maxY) maxY = value;
    }

    // Ajouter une marge de 10%
    final margin = (maxY - minY) * 0.1;
    return (minY - margin, maxY + margin);
  }

  double _calculateAverage() {
    if (vitals.isEmpty) return 0;

    double sum = 0;
    int count = 0;

    for (var vital in vitals) {
      if (type == VitalSignType.bloodPressure && vital.value is String) {
        final components = vital.bloodPressureComponents;
        sum += components?['systolic']?.toDouble() ?? 0;
        count++;
      } else if (vital.value is double) {
        sum += vital.value as double;
        count++;
      } else if (vital.value is int) {
        sum += (vital.value as int).toDouble();
        count++;
      }
    }

    return count > 0 ? sum / count : 0;
  }
}