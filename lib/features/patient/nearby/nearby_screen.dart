import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/doctor_card.dart';
import 'nearby_service.dart';

enum _NearbyTab { clinics, doctors }

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _service = NearbyService();
  final _searchController = TextEditingController();
  final _mapController = MapController();

  bool _loadingLocation = true;
  bool _loadingData = false;
  String? _locationError;

  LatLng? _userLocation;
  List<ClinicProfile> _clinics = [];
  List<DoctorListItem> _doctors = [];
  _NearbyTab _activeTab = _NearbyTab.clinics;
  String? _specialization;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied';
            _loadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission permanently denied. Please enable it in settings.';
          _loadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });

      _mapController.move(_userLocation!, 14);
      await _loadNearby();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Failed to get location: $e';
        _loadingLocation = false;
      });
    }
  }

  Future<void> _loadNearby() async {
    if (_userLocation == null) return;

    setState(() => _loadingData = true);

    try {
      final lat = _userLocation!.latitude;
      final lng = _userLocation!.longitude;

      final clinicsFuture = _service.getNearbyClinics(lat: lat, lng: lng);
      final doctorsFuture = _service.getNearbyDoctors(
        lat: lat,
        lng: lng,
        specialization: _specialization,
      );

      final results = await Future.wait([clinicsFuture, doctorsFuture]);

      if (!mounted) return;
      setState(() {
        _clinics = results[0] as List<ClinicProfile>;
        _doctors = results[1] as List<DoctorListItem>;
        _loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load nearby: $e')),
      );
    }
  }

  void _onSearchSubmitted(String value) {
    _loadNearby();
  }

  void _onSpecializationSelected(String? spec) {
    setState(() => _specialization = spec);
    _loadNearby();
  }

  void _onMarkerTap(int id, bool isClinic) {
    // Center map on tapped marker
    final item = isClinic
        ? _clinics.firstWhere((c) => c.id == id)
        : null;
    final doctor = !isClinic
        ? _doctors.firstWhere((d) => d.id == id)
        : null;

    final lat = item?.latitude ?? doctor?.latitude;
    final lng = item?.longitude ?? doctor?.longitude;
    if (lat != null && lng != null) {
      _mapController.move(LatLng(lat, lng), 16);
    }
  }

  void _navigateToDetail(dynamic item) {
    if (item is DoctorListItem) {
      context.push('${AppRoutes.patientDoctorProfile}/${item.id}');
    } else if (item is ClinicProfile) {
      // Navigate to clinic detail if a route exists; for now show a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} — ${item.address ?? 'No address'}')),
      );
    }
  }

  List<Marker> get _markers {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.my_location, color: AppColors.primary, size: 24),
            ),
          ),
        ),
      );
    }

    for (final clinic in _clinics) {
      if (clinic.latitude == null || clinic.longitude == null) continue;
      markers.add(
        Marker(
          point: LatLng(clinic.latitude!, clinic.longitude!),
          width: 44,
          height: 52,
          child: GestureDetector(
            onTap: () => _onMarkerTap(clinic.id, true),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    clinic.name,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      );
    }

    for (final doctor in _doctors) {
      if (doctor.latitude == null || doctor.longitude == null) continue;
      markers.add(
        Marker(
          point: LatLng(doctor.latitude!, doctor.longitude!),
          width: 44,
          height: 52,
          child: GestureDetector(
            onTap: () => _onMarkerTap(doctor.id, false),
            child: const Column(
              children: [
                Icon(
                  Icons.person_pin_circle,
                  color: AppColors.primaryDark,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<dynamic> get _activeItems {
    final query = _searchController.text.trim().toLowerCase();
    if (_activeTab == _NearbyTab.clinics) {
      return _clinics.where((c) {
        if (query.isEmpty) return true;
        return c.name.toLowerCase().contains(query) ||
            (c.address ?? '').toLowerCase().contains(query) ||
            (c.area ?? '').toLowerCase().contains(query);
      }).toList();
    } else {
      return _doctors.where((d) {
        if (query.isEmpty) return true;
        return d.fullName.toLowerCase().contains(query) ||
            d.specialization.toLowerCase().contains(query) ||
            (d.clinicArea ?? '').toLowerCase().contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: _buildMap(),
          ),

          // Top overlay: search + filters
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildFilterChips(),
              ],
            ),
          ),

          // Bottom sheet: list of nearby items
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(),
          ),

          // Loading overlay
          if (_loadingLocation || _loadingData)
            Positioned.fill(
              child: Container(
                color: AppColors.background.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_loadingLocation && _userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_locationError != null && _userLocation == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text(
                _locationError!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initLocation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final center = _userLocation ?? const LatLng(30.0444, 31.2357); // Default: Cairo

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.medicare.app',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: _activeTab == _NearbyTab.clinics
                    ? 'Search nearby clinics'
                    : 'Search nearby doctors',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textTertiary, size: 20),
              onPressed: () {
                _searchController.clear();
                _loadNearby();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.specializations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final spec = isAll ? null : AppConstants.specializations[index - 1];
          final isSelected = _specialization == spec;
          return ChoiceChip(
            label: Text(isAll ? 'All' : spec!),
            selected: isSelected,
            onSelected: (_) => _onSpecializationSelected(spec),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    final items = _activeItems;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Clinics (${_clinics.length})',
                    isActive: _activeTab == _NearbyTab.clinics,
                    onTap: () => setState(() => _activeTab = _NearbyTab.clinics),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Doctors (${_doctors.length})',
                    isActive: _activeTab == _NearbyTab.doctors,
                    onTap: () => setState(() => _activeTab = _NearbyTab.doctors),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.38,
            ),
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is DoctorListItem) {
                        return DoctorCard(
                          imageAsset: AssetPaths.doctorPhoto1,
                          name: item.fullName,
                          specialization: item.specialization,
                          rating: item.averageRating,
                          reviewsCount: item.totalReviews,
                          fee: item.consultationFee,
                          location: item.clinicArea,
                          isFavorite: item.isFavorited,
                          onFavoriteToggle: () {},
                          onTap: () => _navigateToDetail(item),
                        );
                      } else if (item is ClinicProfile) {
                        return _ClinicListCard(
                          clinic: item,
                          onTap: () => _navigateToDetail(item),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              'No nearby ${_activeTab == _NearbyTab.clinics ? 'clinics' : 'doctors'} found',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ClinicListCard extends StatelessWidget {
  const _ClinicListCard({
    required this.clinic,
    required this.onTap,
  });

  final ClinicProfile clinic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_hospital, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clinic.address ?? clinic.area ?? 'Unknown location',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${clinic.openingTime ?? '--:--'} - ${clinic.closingTime ?? '--:--'}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.people, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${clinic.doctorsCount} doctors',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
