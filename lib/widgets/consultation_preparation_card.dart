import 'package:flutter/material.dart';
import '../models/consultation_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ConsultationPreparationCard extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onPrepare;
  final VoidCallback? onDelete;

  const ConsultationPreparationCard({
    super.key,
    required this.consultation,
    required this.onPrepare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeUntil = consultation.timeUntil;
    final isUrgent = timeUntil.inDays == 0 && timeUntil.inHours < 24;

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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                    borderRadius: AppBorderRadius.circular,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: isUrgent ? AppColors.error : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.doctorName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (consultation.doctorSpecialty != null)
                        Text(
                          consultation.doctorSpecialty!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.error : AppColors.success,
                    borderRadius: AppBorderRadius.sm,
                  ),
                  child: Text(
                    consultation.type.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.labelMedium,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  Helpers.formatDateTime(consultation.scheduledAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                if (isUrgent)
                  const Icon(Icons.warning, size: 16, color: AppColors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPrepare,
                icon: const Icon(Icons.edit_note),
                label: const Text('Préparer ma consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}