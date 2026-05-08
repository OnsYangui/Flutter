import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ml_kit_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final MLKitService _mlKit = MLKitService();
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;
  String? _scannedCode;

  Future<void> _pickImage(ImageSource source) async {
    final feedback = FeedbackService();
    await feedback.vibrate();

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _isScanning = true;
        _scannedCode = null;
      });

      try {
        final code = await _mlKit.scanBarcode(image);

        setState(() {
          _scannedCode = code;
          _isScanning = false;
        });

        await feedback.vibrateSuccess();
      } catch (e) {
        setState(() {
          _isScanning = false;
        });

        await feedback.vibrateError();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isScanning
          ? const LoadingIndicator(message: 'Scanning barcode...')
          : _scannedCode == null
              ? _buildScanPrompt()
              : _buildScanResult(),
    );
  }

  Widget _buildScanPrompt() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Scan Barcode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Scan Medication Barcode',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Point your camera at the medication barcode\nto automatically identify it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey500, fontSize: 16),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _ScanButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScanButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _scannedCode = null),
              ),
              const Text(
                'Scan Result',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppBorderRadius.lg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.03),
                  blurRadius: 20,
                ),
              ],
              border: Border.all(color: AppColors.grey100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Barcode Detected',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: AppBorderRadius.md,
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Text(
                    _scannedCode!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // Usually we would navigate to AddMedication with this code
              // For now just allow rescanning
              setState(() => _scannedCode = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
              elevation: 0,
            ),
            child: const Text('Scan Another Barcode'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ScanButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: AppBorderRadius.lg,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
          border: isPrimary ? null : Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
