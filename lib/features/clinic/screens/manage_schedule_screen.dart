import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../clinic/clinic_service.dart';

class ManageScheduleScreen extends StatefulWidget {
  final int doctorId;

  const ManageScheduleScreen({super.key, required this.doctorId});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final _service = ClinicService();
  bool _isLoading = false;
  bool _isFetching = true;

  final List<String> _days = [
    'Sunday',    // 0
    'Monday',    // 1
    'Tuesday',   // 2
    'Wednesday', // 3
    'Thursday',  // 4
    'Friday',    // 5
    'Saturday',  // 6
  ];

  int _selectedDayIndex = 0;

  /// Schedule data per day: id (null for new), start, end, slotDurationMinutes, maxPatients
  final Map<int, List<Map<String, dynamic>>> _schedules = {};

  /// Tracks which day indices have changes (new or deleted slots)
  final Set<int> _dirtyDays = {};

  /// Tracks schedule IDs that were removed and need to be deleted from backend
  final Set<int> _deletedScheduleIds = {};

  String? _clinicOpeningTime;
  String? _clinicClosingTime;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isFetching = true);
    try {
      final profileFuture = _service.getClinicProfile();
      final schedulesFuture = _service.getDoctorSchedules(widget.doctorId);
      final results = await Future.wait([profileFuture, schedulesFuture]);
      final profile = results[0] as ClinicProfile;
      final schedules = results[1] as List<DoctorSchedule>;
      
      final grouped = <int, List<Map<String, dynamic>>>{};
      for (final s in schedules) {
        grouped.putIfAbsent(s.dayOfWeek, () => []).add({
          'id': s.id,
          'start': s.startTime,
          'end': s.endTime,
          'slotDurationMinutes': s.slotDurationMinutes,
          'maxPatients': s.maxPatients,
        });
      }
      for (int i = 0; i < 7; i++) {
        _schedules[i] = grouped[i] ?? [];
      }
      
      if (mounted) {
        setState(() {
          _clinicOpeningTime = profile.openingTime;
          _clinicClosingTime = profile.closingTime;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${errorMessage(e)}')),
        );
      }
      for (int i = 0; i < 7; i++) {
        _schedules[i] = [];
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    try {
      // Delete removed schedules first
      for (final scheduleId in _deletedScheduleIds) {
        await _service.deleteSchedule(scheduleId);
      }

      // Collect new schedules (those without an ID)
      final newScheduleData = <Map<String, dynamic>>[];
      for (final dayIndex in _dirtyDays) {
        for (final slot in _schedules[dayIndex] ?? []) {
          if (slot['id'] == null) {
            newScheduleData.add({
              'dayOfWeek': dayIndex,
              'startTime': slot['start'] as String,
              'endTime': slot['end'] as String,
              'slotDurationMinutes': slot['slotDurationMinutes'] as int? ?? 30,
              'maxPatients': slot['maxPatients'] as int? ?? 10,
            });
          }
        }
      }

      if (newScheduleData.isNotEmpty) {
        await _service.updateDoctorSchedule(widget.doctorId, newScheduleData);
      }

      if (mounted) {
        _dirtyDays.clear();
        _deletedScheduleIds.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTimeSlot() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final durationController = TextEditingController(text: '30');
    final maxPatientsController = TextEditingController(text: '10');

    final clinicOpen = _parseTime(_clinicOpeningTime) ?? const TimeOfDay(hour: 10, minute: 0);
    final clinicClose = _parseTime(_clinicClosingTime) ?? const TimeOfDay(hour: 20, minute: 0);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Time Slot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Clinic hours: ${_formatTimeOfDay(clinicOpen)} - ${_formatTimeOfDay(clinicClose)}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? clinicOpen,
                    );
                    if (picked != null) {
                      setDialogState(() => startTime = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          startTime != null
                              ? _formatTimeOfDay(startTime!)
                              : 'Select start time',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime ?? clinicClose,
                    );
                    if (picked != null) {
                      setDialogState(() => endTime = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          endTime != null
                              ? _formatTimeOfDay(endTime!)
                              : 'Select end time',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Slot Duration (minutes)',
                    hintText: '30',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxPatientsController,
                  decoration: const InputDecoration(
                    labelText: 'Max Patients',
                    hintText: '10',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (startTime == null || endTime == null) return;
                
                final startMinutes = startTime!.hour * 60 + startTime!.minute;
                final endMinutes = endTime!.hour * 60 + endTime!.minute;
                final clinicOpenMinutes = clinicOpen.hour * 60 + clinicOpen.minute;
                final clinicCloseMinutes = clinicClose.hour * 60 + clinicClose.minute;

                if (startMinutes < clinicOpenMinutes || endMinutes > clinicCloseMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Times must be within clinic hours (${_formatTimeOfDay(clinicOpen)} - ${_formatTimeOfDay(clinicClose)})',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (endMinutes <= startMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(context, {
                  'start': '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00',
                  'end': '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00',
                  'slotDurationMinutes': int.tryParse(durationController.text.trim()) ?? 30,
                  'maxPatients': int.tryParse(maxPatientsController.text.trim()) ?? 10,
                });
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _schedules[_selectedDayIndex] ??= [];
        _schedules[_selectedDayIndex]!.add(result);
        _dirtyDays.add(_selectedDayIndex);
      });
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _removeTimeSlot(int index) {
    setState(() {
      final slot = _schedules[_selectedDayIndex]?[index];
      if (slot != null && slot['id'] != null) {
        _deletedScheduleIds.add(slot['id'] as int);
      }
      _schedules[_selectedDayIndex]?.removeAt(index);
      _dirtyDays.add(_selectedDayIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSlots = _schedules[_selectedDayIndex] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isFetching
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_clinicOpeningTime != null && _clinicClosingTime != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Clinic Hours: $_clinicOpeningTime - $_clinicClosingTime',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildDaySelector(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: currentSlots.isEmpty
                        ? _buildEmptySlots()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: currentSlots.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final slot = currentSlots[index];
                              return _TimeSlotCard(
                                startTime: slot['start'] as String? ?? '--:--',
                                endTime: slot['end'] as String? ?? '--:--',
                                slotDurationMinutes: slot['slotDurationMinutes'] as int? ?? 30,
                                maxPatients: slot['maxPatients'] as int? ?? 10,
                                onDelete: () => _removeTimeSlot(index),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      children: [
                        AppButton(
                          text: 'Add Time Slot',
                          isOutlined: true,
                          icon: Icons.add,
                          onPressed: _addTimeSlot,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Save Schedule',
                          isLoading: _isLoading,
                          onPressed: _saveSchedule,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          final hasSlots = (_schedules[index] ?? []).isNotEmpty;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[index].substring(0, 3),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasSlots)
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySlots() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            children: [
              Icon(Icons.schedule, size: 56, color: AppColors.textTertiary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'No time slots',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Add time slots for ${_days[_selectedDayIndex]}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int maxPatients;
  final VoidCallback onDelete;

  const _TimeSlotCard({
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.maxPatients,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$startTime - $endTime',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$slotDurationMinutes min slots · $maxPatients max patients',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
