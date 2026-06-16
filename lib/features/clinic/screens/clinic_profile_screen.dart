import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/debug_account_switcher.dart';
import '../../clinic/clinic_service.dart';

class ClinicProfileScreen extends StatefulWidget {
  const ClinicProfileScreen({super.key});

  @override
  State<ClinicProfileScreen> createState() => _ClinicProfileScreenState();
}

class _ClinicProfileScreenState extends State<ClinicProfileScreen> {
  final _service = ClinicService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final profile = await _service.getClinicProfile();
      setState(() {
        _profileData = profile.toJson();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profileData?['name'] ?? '';
    final facilityId = _profileData?['facilityId'] as String?;
    final description = _profileData?['description'] as String?;
    final government = _profileData?['government'] as String?;
    final area = _profileData?['area'] as String?;
    final address = _profileData?['address'] as String?;
    final phoneNumber = _profileData?['phoneNumber'] as String?;
    final email = _profileData?['email'] as String?;
    final logoUrl = _profileData?['logoUrl'] as String?;
    final doctorsCount = _profileData?['doctorsCount'] ?? 0;
    final isActive = _profileData?['isActive'] ?? false;
    final latitude = _profileData?['latitude'] as double?;
    final longitude = _profileData?['longitude'] as double?;
    final openingTime = _profileData?['openingTime'] as String?;
    final closingTime = _profileData?['closingTime'] as String?;
    final linkMap = _profileData?['linkMap'] as String?;
    final licenseImageUrl = _profileData?['licenseImageUrl'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinic Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.clinicEditProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      child: Column(
                        children: [
                          _buildProfileHeader(name, logoUrl, isActive),
                          const SizedBox(height: 24),
                          _buildInfoSection(
                            title: 'Basic Information',
                            items: [
                              if (facilityId != null)
                                _InfoItem(icon: Icons.badge, label: 'Facility ID', value: facilityId),
                              if (description != null)
                                _InfoItem(icon: Icons.description, label: 'Description', value: description),
                              if (linkMap != null)
                                _InfoItem(icon: Icons.map, label: 'Google Maps', value: linkMap),
                              if (licenseImageUrl != null)
                                _InfoItem(icon: Icons.verified, label: 'License', value: licenseImageUrl),
                              _InfoItem(
                                icon: Icons.people,
                                label: 'Doctors',
                                value: '$doctorsCount doctors',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            title: 'Location',
                            items: [
                              if (government != null)
                                _InfoItem(icon: Icons.location_city, label: 'Government', value: government),
                              if (area != null)
                                _InfoItem(icon: Icons.map, label: 'Area', value: area),
                              if (address != null)
                                _InfoItem(icon: Icons.home, label: 'Address', value: address),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            title: 'Contact',
                            items: [
                              if (phoneNumber != null)
                                _InfoItem(icon: Icons.phone, label: 'Phone', value: phoneNumber),
                              if (email != null)
                                _InfoItem(icon: Icons.email, label: 'Email', value: email),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            title: 'Location Coordinates',
                            items: [
                              if (latitude != null)
                                _InfoItem(icon: Icons.explore, label: 'Latitude', value: latitude.toString()),
                              if (longitude != null)
                                _InfoItem(icon: Icons.explore, label: 'Longitude', value: longitude.toString()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoSection(
                            title: 'Operating Hours',
                            items: [
                              if (openingTime != null)
                                _InfoItem(icon: Icons.access_time, label: 'Opening Time', value: openingTime),
                              if (closingTime != null)
                                _InfoItem(icon: Icons.access_time_filled, label: 'Closing Time', value: closingTime),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push(AppRoutes.clinicEditProfile),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('Logout'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                          ),
                          if (kEnableDebugTools) ...[
                            const DebugAccountSwitcher(),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? logoUrl, bool isActive) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
              image: logoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage(AssetPaths.clinicImage1),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.successBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<_InfoItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...items.map((item) => _buildInfoRow(item)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}
