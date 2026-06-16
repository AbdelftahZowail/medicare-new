import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/error_utils.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/location_picker_sheet.dart';
import '../../clinic/clinic_service.dart';

class EditClinicProfileScreen extends StatefulWidget {
  const EditClinicProfileScreen({super.key});

  @override
  State<EditClinicProfileScreen> createState() => _EditClinicProfileScreenState();
}

class _EditClinicProfileScreenState extends State<EditClinicProfileScreen> {
  final _service = ClinicService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _facilityIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _governmentController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _linkMapController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _logoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getClinicProfile();
      _nameController.text = profile.name;
      _facilityIdController.text = profile.facilityId ?? '';
      _descriptionController.text = profile.description ?? '';
      _governmentController.text = profile.government ?? '';
      _areaController.text = profile.area ?? '';
      _addressController.text = profile.address ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
      _emailController.text = profile.email ?? '';
      _latitudeController.text = profile.latitude?.toString() ?? '';
      _longitudeController.text = profile.longitude?.toString() ?? '';
      _openingTimeController.text = profile.openingTime ?? '';
      _closingTimeController.text = profile.closingTime ?? '';
      _linkMapController.text = profile.linkMap ?? '';
      _logoUrl = profile.logoUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to load profile: ${errorMessage(e)}'
                : 'Failed to load profile. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickOpeningTime() async {
    final parts = _openingTimeController.text.split(':');
    final initialHour = parts.length >= 1 ? int.tryParse(parts[0]) ?? 9 : 9;
    final initialMinute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      _openingTimeController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    }
  }

  Future<void> _pickClosingTime() async {
    final parts = _closingTimeController.text.split(':');
    final initialHour = parts.length >= 1 ? int.tryParse(parts[0]) ?? 17 : 17;
    final initialMinute = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      _closingTimeController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'facilityId': _facilityIdController.text.trim().isEmpty ? null : _facilityIdController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'government': _governmentController.text.trim().isEmpty ? null : _governmentController.text.trim(),
        'area': _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'latitude': _latitudeController.text.trim().isEmpty ? null : double.tryParse(_latitudeController.text.trim()),
        'longitude': _longitudeController.text.trim().isEmpty ? null : double.tryParse(_longitudeController.text.trim()),
        'openingTime': _openingTimeController.text.trim().isEmpty ? null : _openingTimeController.text.trim(),
        'closingTime': _closingTimeController.text.trim().isEmpty ? null : _closingTimeController.text.trim(),
        'logoUrl': _logoUrl,
        'linkMap': _linkMapController.text.trim().isEmpty ? null : _linkMapController.text.trim(),
      };

      await _service.updateClinicProfile(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to save profile: ${errorMessage(e)}'
                : 'Failed to save profile. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickLocationOnMap() async {
    double? initialLat;
    double? initialLng;
    if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty) {
      initialLat = double.tryParse(_latitudeController.text.trim());
      initialLng = double.tryParse(_longitudeController.text.trim());
    }

    final picked = await showLocationPicker(
      context: context,
      initialLocation: (initialLat != null && initialLng != null)
          ? LatLng(initialLat!, initialLng!)
          : null,
    );
    if (picked != null && mounted) {
      setState(() {
        _latitudeController.text = picked.latitude.toString();
        _longitudeController.text = picked.longitude.toString();
      });
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final response = await ApiService().uploadFile(
        ApiEndpoints.uploadProfileImage,
        filePath: pickedFile.path,
        fieldName: 'file',
      );

      if (response.isSuccess && response.data != null) {
        final url = response.data!['url'] as String?;
        if (url != null && url.isNotEmpty) {
          setState(() {
            _logoUrl = url;
            _isUploading = false;
          });
          return;
        }
      }

      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload logo')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to upload logo: ${errorMessage(e)}'
                : 'Failed to upload logo. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facilityIdController.dispose();
    _descriptionController.dispose();
    _governmentController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _linkMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogoUpload(),
                      const SizedBox(height: 24),
                      Text('Basic Information', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Clinic Name',
                        hint: 'Enter clinic name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Facility ID',
                        hint: 'Enter facility ID',
                        controller: _facilityIdController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description',
                        hint: 'Enter clinic description',
                        controller: _descriptionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Google Maps Link',
                        hint: 'Paste Google Maps link',
                        controller: _linkMapController,
                      ),
                      const SizedBox(height: 24),
                      Text('Location', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Government',
                        hint: 'Enter government',
                        controller: _governmentController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Area',
                        hint: 'Enter area',
                        controller: _areaController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Address',
                        hint: 'Enter full address',
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Latitude',
                              hint: 'Enter latitude',
                              controller: _latitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Longitude',
                              hint: 'Enter longitude',
                              controller: _longitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickLocationOnMap,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Pick on Map'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Contact', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Text('Operating Hours', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickOpeningTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Opening Time', style: AppTextStyles.labelLarge),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          _openingTimeController.text.isNotEmpty
                                              ? _openingTimeController.text
                                              : 'Set time',
                                          style: AppTextStyles.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickClosingTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Closing Time', style: AppTextStyles.labelLarge),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          _closingTimeController.text.isNotEmpty
                                              ? _closingTimeController.text
                                              : 'Set time',
                                          style: AppTextStyles.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: 'Save Changes',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Cancel',
                        isOutlined: true,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLogoUpload() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
              image: _logoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(ApiEndpoints.resolveImageUrl(_logoUrl)!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _logoUrl == null
                ? const Icon(Icons.local_hospital, color: AppColors.primary, size: 50)
                : _isUploading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : null,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isUploading ? null : _pickAndUploadLogo,
            icon: _isUploading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.camera_alt, size: 18),
            label: const Text('Change Logo'),
          ),
        ],
      ),
    );
  }
}
