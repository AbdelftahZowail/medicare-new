import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final List<String> _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  int _selectedDayIndex = 0;

  // Mock schedule data per day
  final Map<int, List<Map<String, String>>> _schedules = {
    0: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    1: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    2: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    3: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    4: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    5: [
      {'start': '09:00', 'end': '12:00'},
      {'start': '14:00', 'end': '17:00'},
    ],
    6: [],
  };

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    try {
      final scheduleData = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
        for (final slot in _schedules[i] ?? []) {
          scheduleData.add({
            'dayOfWeek': i,
            'startTime': slot['start'],
            'endTime': slot['end'],
            'slotDurationMinutes': 30,
            'maxPatients': 10,
          });
        }
      }

      await _service.updateDoctorSchedule(widget.doctorId, {
        'schedules': scheduleData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved successfully')),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTimeSlot() async {
    final startController = TextEditingController();
    final endController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Time Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Start Time (HH:MM)',
                hintText: '09:00',
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'End Time (HH:MM)',
                hintText: '12:00',
              ),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (startController.text.isNotEmpty && endController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'start': startController.text,
                  'end': endController.text,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _schedules[_selectedDayIndex] ??= [];
        _schedules[_selectedDayIndex]!.add(result);
      });
    }
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _schedules[_selectedDayIndex]?.removeAt(index);
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
        child: Column(
          children: [
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
                          startTime: slot['start'] ?? '--:--',
                          endTime: slot['end'] ?? '--:--',
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
  final VoidCallback onDelete;

  const _TimeSlotCard({
    required this.startTime,
    required this.endTime,
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
                  '30 min slots · 10 max patients',
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
