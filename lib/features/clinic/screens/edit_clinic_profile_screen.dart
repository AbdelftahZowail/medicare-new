import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
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
      _logoUrl = profile.logoUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }
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
                      image: NetworkImage(_logoUrl!),
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
