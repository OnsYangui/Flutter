import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isScanned = prescription.originalText != null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isScanned ? Colors.orange : AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isScanned ? Icons.qr_code_scanner : Icons.description,
                  color: isScanned ? Colors.orange : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${prescription.doctorName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Délivrée le ${Helpers.formatDate(prescription.issueDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (prescription.medicationIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${prescription.medicationIds.length} médicament(s)',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(prescription.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prescription.status.label,
                      style: TextStyle(
                        color: _getStatusColor(prescription.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.active:
        return AppColors.success;
      case PrescriptionStatus.expired:
        return AppColors.error;
      case PrescriptionStatus.archived:
        return Colors.grey;
    }
  }
}
