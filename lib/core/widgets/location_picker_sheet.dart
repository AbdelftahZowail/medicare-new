import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Shows a full-screen map picker with place search and returns the selected [LatLng], or null if cancelled.
Future<LatLng?> showLocationPicker({
  required BuildContext context,
  LatLng? initialLocation,
}) {
  return showModalBottomSheet<LatLng>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (ctx) => _LocationPickerBody(initialLocation: initialLocation),
  );
}

class _NominatimResult {
  final String displayName;
  final double lat;
  final double lon;

  const _NominatimResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory _NominatimResult.fromJson(Map<String, dynamic> json) {
    return _NominatimResult(
      displayName: json['display_name'] as String? ?? '',
      lat: double.parse((json['lat'] as String?) ?? '0'),
      lon: double.parse((json['lon'] as String?) ?? '0'),
    );
  }
}

class _LocationPickerBody extends StatefulWidget {
  final LatLng? initialLocation;

  const _LocationPickerBody({this.initialLocation});

  @override
  State<_LocationPickerBody> createState() => _LocationPickerBodyState();
}

class _LocationPickerBodyState extends State<_LocationPickerBody> {
  late final MapController _mapController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  LatLng? _pickedLocation;
  Timer? _debounce;
  List<_NominatimResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  static const _defaultLocation = LatLng(30.0444, 31.2357); // Cairo

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _pickedLocation = widget.initialLocation ?? _defaultLocation;

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        // Delay so tap on a result fires before hiding
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocus.hasFocus) {
            setState(() => _showResults = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapMoved(MapCamera camera) {
    setState(() => _pickedLocation = camera.center);
  }

  void _confirm() {
    if (_pickedLocation != null) {
      Navigator.of(context).pop(_pickedLocation);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _searchPlaces(query));
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isSearching = true);

    try {
      final response = await Dio().getUri(
        Uri.https(
          'nominatim.openstreetmap.org',
          '/search',
          {
            'q': query.trim(),
            'format': 'json',
            'limit': '5',
            'countrycodes': 'eg',
            'accept-language': 'en',
          },
        ),
        options: Options(
          headers: {
            'User-Agent': 'medicare-app/1.0',
          },
          responseType: ResponseType.json,
        ),
      );

      final list = (response.data as List<dynamic>?)
          ?.map((e) => _NominatimResult.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      if (mounted) {
        setState(() {
          _searchResults = list;
          _showResults = list.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _showResults = false;
          _isSearching = false;
        });
      }
    }
  }

  void _onPlaceSelected(_NominatimResult place) {
    _searchController.text = place.displayName;
    _searchFocus.unfocus();
    setState(() {
      _pickedLocation = LatLng(place.lat, place.lon);
      _showResults = false;
    });
    _mapController.move(LatLng(place.lat, place.lon), 16);
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = widget.initialLocation ?? _defaultLocation;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              children: [
                Text('Select Clinic Location', style: AppTextStyles.heading2),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              onTap: () {
                if (_searchResults.isNotEmpty) {
                  setState(() => _showResults = true);
                }
              },
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search for a place…',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                prefixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textTertiary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          setState(() {
                            _searchResults = [];
                            _showResults = false;
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Map + search results overlay
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: (_, __) {
                      _searchFocus.unfocus();
                      setState(() => _showResults = false);
                    },
                    onMapEvent: (event) {
                      if (event is MapEventMove ||
                          event is MapEventFlingAnimation ||
                          event is MapEventMoveEnd) {
                        _onMapMoved(event.camera);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.medicare.app',
                    ),
                  ],
                ),

                // Center crosshair
                const Center(
                  child: IgnorePointer(
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                ),

                // Search results dropdown
                if (_showResults && _searchResults.isNotEmpty)
                  Positioned(
                    top: 4,
                    left: 12,
                    right: 12,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.surface,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _searchResults.map((result) {
                            return InkWell(
                              onTap: () => _onPlaceSelected(result),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        result.displayName,
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Coordinate display + confirm
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.pin_drop, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _pickedLocation != null
                        ? '${_pickedLocation!.latitude.toStringAsFixed(6)}, ${_pickedLocation!.longitude.toStringAsFixed(6)}'
                        : 'Move map to select location',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _pickedLocation != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confirm button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, mediaQuery.padding.bottom + 12),
            child: AppButton(
              text: 'Confirm Location',
              icon: Icons.check,
              onPressed: _pickedLocation != null ? _confirm : null,
            ),
          ),
        ],
      ),
    );
  }
}
