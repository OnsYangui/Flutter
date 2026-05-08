import 'package:flutter/material.dart';
import '../models/medication_model.dart';
import '../utils/constants.dart';
import '../utils/theme_colors.dart';
import '../utils/helpers.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;
  final VoidCallback? onTake;
  final VoidCallback? onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
    this.onTake,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lg,
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.lg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: medication.type.color.withOpacity(0.1),
                      borderRadius: AppBorderRadius.lg,
                    ),
                    child: Icon(medication.type.icon, color: medication.type.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosage,
                          style: const TextStyle(
                            color: AppColors.grey500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    _ActionIcon(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade50,
                      iconColor: Colors.red,
                      onTap: onDelete!,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _InfoBadge(
                    icon: Icons.access_time_outlined,
                    label: medication.times.map((t) => Helpers.formatTime(t)).join(', '),
                  ),
                  const SizedBox(width: 12),
                  _InfoBadge(
                    icon: Icons.repeat,
                    label: medication.frequency,
                  ),
                ],
              ),
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.bgSecondary,
                    borderRadius: AppBorderRadius.md,
                  ),
                  child: Text(
                    medication.notes!,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (onTake != null && medication.isActive) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onTake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.md,
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      const Text('Marquer comme pris'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}