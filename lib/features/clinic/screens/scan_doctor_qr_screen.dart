import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../clinic/clinic_service.dart';

class ScanDoctorQrScreen extends StatefulWidget {
  const ScanDoctorQrScreen({super.key});

  @override
  State<ScanDoctorQrScreen> createState() => _ScanDoctorQrScreenState();
}

class _ScanDoctorQrScreenState extends State<ScanDoctorQrScreen> {
  final _service = ClinicService();
  final _qrController = TextEditingController();
  bool _isScanning = true;
  bool _isLoading = false;
  Map<String, dynamic>? _scannedDoctor;
  String? _error;

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final qrCode = _qrController.text.trim();
    if (qrCode.isEmpty) {
      setState(() => _error = 'Please enter a QR code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.scanDoctorQr(qrCode);
      setState(() {
        // Normalize field names: the backend may return 'doctorId' instead of 'id'
        // and 'defaultConsultationFee' instead of 'consultationFee'
        _scannedDoctor = {
          'id': data['doctorId'] ?? data['id'] ?? 0,
          'fullName': data['fullName'] ?? '',
          'specialization': data['specialization'] ?? '',
          'profileImageUrl': data['profileImageUrl'],
          'consultationFee': data['defaultConsultationFee'] ?? data['consultationFee'] ?? 0.0,
          'averageRating': data['averageRating'] ?? 0.0,
          'totalReviews': data['totalReviews'] ?? 0,
          'qrCodeKey': data['qrCodeKey'] ?? data['doctorQrCodeKey'],
        };
        _isScanning = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _registerDoctor() {
    context.push(AppRoutes.clinicRegisterDoctor, extra: _scannedDoctor);
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _scannedDoctor = null;
      _error = null;
      _qrController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Doctor QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isScanning ? _buildScannerView() : _buildResultView(),
      ),
    );
  }

  Widget _buildScannerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Camera Preview',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Point camera at doctor\'s QR code',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Or enter QR code manually',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qrController,
            decoration: InputDecoration(
              hintText: 'Enter QR code key',
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            text: 'Scan',
            isLoading: _isLoading,
            onPressed: _scanQr,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final doctor = _scannedDoctor!;
    final name = doctor['fullName'] ?? '';
    final specialization = doctor['specialization'] ?? '';
    final imageUrl = doctor['profileImageUrl'] as String?;
    final fee = (doctor['consultationFee'] as num?)?.toDouble() ?? 0.0;
    final rating = (doctor['averageRating'] as num?)?.toDouble() ?? 0.0;
    final reviews = doctor['totalReviews'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    shape: BoxShape.circle,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary, size: 45)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(name, style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($reviews reviews)',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_money, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Default Fee: \$${fee.toStringAsFixed(2)}',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Register to Clinic',
            onPressed: _registerDoctor,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Scan Another',
            isOutlined: true,
            onPressed: _resetScan,
          ),
        ],
      ),
    );
  }
}
