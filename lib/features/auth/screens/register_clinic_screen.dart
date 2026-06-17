import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/error_utils.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/location_picker_sheet.dart';
import '../widgets/auth_layout.dart';
import '../widgets/dashed_upload.dart';

class RegisterClinicScreen extends StatefulWidget {
  const RegisterClinicScreen({super.key});

  @override
  State<RegisterClinicScreen> createState() => _RegisterClinicScreenState();
}

class _RegisterClinicScreenState extends State<RegisterClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _linkMapController = TextEditingController();
  String? _government;
  String? _area;
  bool _obscure = true;
  bool _obscure2 = true;

  String? _licenseFilePath;
  String? _licenseFileUrl;
  bool _isUploading = false;
  String? _logoUrl;
  bool _isUploadingLogo = false;

  // ── Debug auto-fill ──
  int _debugPreset = 0;
  static const _debugPresets = [
    {'name': 'Medicare Clinic', 'linkMap': 'https://maps.app.goo.gl/example1', 'gov': 'Cairo', 'area': 'Area 1', 'addr': '15 Tahrir Street, Maadi', 'lat': '29.9608', 'lng': '31.2707', 'phone': '0223456789', 'email': 'medicare@test.com', 'open': '09:00:00', 'close': '21:00:00'},
    {'name': 'Nile Health Center', 'linkMap': 'https://maps.app.goo.gl/example2', 'gov': 'Giza', 'area': 'Area 2', 'addr': '22 Nile Corniche, Dokki', 'lat': '30.0395', 'lng': '31.2025', 'phone': '0238765432', 'email': 'nile.health@test.com', 'open': '08:00:00', 'close': '22:00:00'},
    {'name': 'Prime Medical Complex', 'linkMap': 'https://maps.app.goo.gl/example3', 'gov': 'Alexandria', 'area': 'Area 3', 'addr': '8 Gamal Nasser Rd, Smouha', 'lat': '31.2100', 'lng': '29.9187', 'phone': '0311223344', 'email': 'prime@test.com', 'open': '10:00:00', 'close': '20:00:00'},
    {'name': 'Al Salam Hospital', 'linkMap': 'https://maps.app.goo.gl/example4', 'gov': 'Sharqia', 'area': 'Area 1', 'addr': '55 Geish Street, Zagazig', 'lat': '30.5877', 'lng': '31.5020', 'phone': '0559988776', 'email': 'salam@test.com', 'open': '00:00:00', 'close': '23:59:00'},
  ];

  void _fillDebugFields() {
    final p = _debugPresets[_debugPreset % _debugPresets.length];
    _debugPreset++;
    setState(() {
      _clinicNameController.text = p['name'] as String;
      _linkMapController.text = p['linkMap'] as String;
      _government = p['gov'] as String;
      _area = p['area'] as String;
      _addressController.text = p['addr'] as String;
      _latitudeController.text = p['lat'] as String;
      _longitudeController.text = p['lng'] as String;
      _phoneController.text = p['phone'] as String;
      _emailController.text = p['email'] as String;
      _openingTimeController.text = p['open'] as String;
      _closingTimeController.text = p['close'] as String;
    });
  }

  final _governments = const [
    'Cairo',
    'Giza',
    'Alexandria',
    'Dakahlia',
    'Sharqia',
  ];

  final _areas = const [
    'Area 1',
    'Area 2',
    'Area 3',
  ];

  @override
  void dispose() {
    _clinicNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _linkMapController.dispose();
    super.dispose();
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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_licenseFileUrl == null || _licenseFileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your clinic license')),
      );
      return;
    }

    double? latitude;
    double? longitude;
    if (_latitudeController.text.isNotEmpty) {
      latitude = double.tryParse(_latitudeController.text.trim());
    }
    if (_longitudeController.text.isNotEmpty) {
      longitude = double.tryParse(_longitudeController.text.trim());
    }

    context.read<AuthBloc>().add(
          AuthRegisterClinicRequested(
            RegisterClinicRequest(
              clinicName: _clinicNameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
              government: _government,
              area: _area,
              address: _addressController.text.trim().isNotEmpty
                  ? _addressController.text.trim()
                  : null,
              email: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              latitude: latitude,
              longitude: longitude,
              openingTime: _openingTimeController.text.trim().isNotEmpty
                  ? _openingTimeController.text.trim()
                  : null,
              closingTime: _closingTimeController.text.trim().isNotEmpty
                  ? _closingTimeController.text.trim()
                  : null,
              licenseFileUrl: _licenseFileUrl!,
              linkMap: _linkMapController.text.trim().isNotEmpty
                  ? _linkMapController.text.trim()
                  : null,
              logoUrl: _logoUrl,
            ),
          ),
        );
  }

  Future<void> _pickAndUploadLicense() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _licenseFilePath = pickedFile.path;
        _isUploading = true;
      });

      final response = await ApiService().uploadFile(
        ApiEndpoints.uploadLicense,
        filePath: pickedFile.path,
        fieldName: 'file',
      );

      if (response.isSuccess && response.data != null) {
        final url = response.data!['url'] as String?;
        if (url != null && url.isNotEmpty) {
          setState(() {
            _licenseFileUrl = url;
            _isUploading = false;
          });
          return;
        }
      }

      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload license')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Upload error: ${errorMessage(e)}'
                : 'Failed to upload license. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploadingLogo = true);

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
            _isUploadingLogo = false;
          });
          return;
        }
      }

      setState(() => _isUploadingLogo = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload logo')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingLogo = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Upload error: ${errorMessage(e)}'
                : 'Failed to upload logo. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      floatingActionButton: kEnableDebugTools
          ? FloatingActionButton.small(
              heroTag: 'fill_clinic',
              onPressed: _fillDebugFields,
              child: const Icon(Icons.auto_fix_high),
            )
          : null,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => c is AuthFailure,
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),
                Text('Sign Up', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: 14),
                Text('Create Account For Clinic', style: AppTextStyles.heading2),
                const SizedBox(height: 6),
                Text(
                  'Please enter your information and create your account',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildLogoUpload(),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Name',
                        hint: 'Enter Clinic Name',
                        controller: _clinicNameController,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Clinic name is required';
                          if (value.length < 2) return 'Enter a valid clinic name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Location', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledDropdown(
                              label: 'Government',
                              hint: 'Government',
                              value: _government,
                              items: _governments,
                              onChanged: (v) => setState(() => _government = v),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledDropdown(
                              label: 'Area',
                              hint: 'Area',
                              value: _area,
                              items: _areas,
                              onChanged: (v) => setState(() => _area = v),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Address',
                        hint: 'Enter full address',
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Google Maps Link',
                        hint: 'Paste Google Maps link',
                        controller: _linkMapController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickLocationOnMap,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Pick on Map'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Contact', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Phone',
                        hint: 'Enter Your Phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Phone is required';
                          if (value.length < 8) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      Text('Operating Hours', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 14),
                      DashedUploadPlaceholder(
                        title: 'Upload clinic license',
                        subtitle: 'Tap to upload',
                        fileName: _licenseFilePath != null
                            ? File(_licenseFilePath!).path.split(Platform.pathSeparator).last
                            : null,
                        isLoading: _isUploading,
                        onTap: _pickAndUploadLicense,
                      ),
                      const SizedBox(height: 20),
                      Text('Account Security', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter Your Password',
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm Your Password',
                        controller: _confirmController,
                        obscureText: _obscure2,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) return 'Confirm password is required';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return AppButton(
                            text: 'Sign Up',
                            isLoading: loading,
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Have an account? ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text('Login', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                : _isUploadingLogo
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : null,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isUploadingLogo ? null : _pickAndUploadLogo,
            icon: _isUploadingLogo
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.camera_alt, size: 18),
            label: const Text('Upload Logo'),
          ),
        ],
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _LabeledDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }
}
