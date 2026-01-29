import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/month_calendar_widget.dart';
import './widgets/preparation_tips_widget.dart';
import './widgets/session_summary_widget.dart';
import './widgets/time_slot_widget.dart';

class CalendarBookingScreen extends StatefulWidget {
  const CalendarBookingScreen({super.key});

  @override
  State<CalendarBookingScreen> createState() => _CalendarBookingScreenState();
}

class _CalendarBookingScreenState extends State<CalendarBookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  String? _selectedPackage;
  bool _isLoading = false;
  bool _showTimeSlots = false;

  final Map<String, dynamic> _mentorData = {
    'id': 'mentor_001',
    'name': 'Dr. Priya Sharma',
    'photo':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1d11b2309-1763297221939.png',
    'photoSemanticLabel':
        'Professional headshot of Indian woman with long black hair wearing navy blazer and white shirt',
    'expertise': 'Data Science & Machine Learning',
    'rating': 4.9,
    'reviews': 156,
  };

  final List<Map<String, dynamic>> _coursePackages = [
    {
      'id': 'free_demo',
      'name': 'Free Demo Session',
      'duration': '1 Session',
      'price': 0,
      'description': 'Try before you commit',
      'badge': 'FREE',
    },
    {
      'id': '3_month',
      'name': '3 Month Course',
      'duration': '12 Sessions',
      'price': 6000,
      'description': 'Perfect for beginners',
      'badge': null,
    },
    {
      'id': '6_month',
      'name': '6 Month Course',
      'duration': '24 Sessions',
      'price': 8000,
      'description': 'Most popular choice',
      'badge': 'POPULAR',
    },
    {
      'id': '12_month',
      'name': '12 Month Course',
      'duration': '48 Sessions',
      'price': 12000,
      'description': 'Complete mastery program',
      'badge': 'BEST VALUE',
    },
  ];

  final List<DateTime> _availableDates = [
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 7)),
    DateTime.now().add(const Duration(days: 8)),
    DateTime.now().add(const Duration(days: 10)),
    DateTime.now().add(const Duration(days: 12)),
    DateTime.now().add(const Duration(days: 14)),
    DateTime.now().add(const Duration(days: 15)),
  ];

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '09:00 AM - 09:30 AM', 'isAvailable': true},
    {'time': '10:00 AM - 10:30 AM', 'isAvailable': true},
    {'time': '11:00 AM - 11:30 AM', 'isAvailable': false},
    {'time': '02:00 PM - 02:30 PM', 'isAvailable': true},
    {'time': '03:00 PM - 03:30 PM', 'isAvailable': true},
    {'time': '04:00 PM - 04:30 PM', 'isAvailable': true},
    {'time': '05:00 PM - 05:30 PM', 'isAvailable': false},
    {'time': '06:00 PM - 06:30 PM', 'isAvailable': true},
  ];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTime = null;
      _showTimeSlots = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToTimeSlots();
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _scrollToTimeSlots() {
    // Scroll implementation would use ScrollController in production
  }

  void _onTimeSlotSelected(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _onPackageSelected(String packageId) {
    setState(() {
      _selectedPackage = packageId;
    });
  }

  Future<void> _proceedToPayment() async {
    if (_selectedDay == null ||
        _selectedTime == null ||
        _selectedPackage == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedPackageData = _coursePackages.firstWhere(
        (pkg) => pkg['id'] == _selectedPackage,
      );

      if (_selectedPackage == 'free_demo') {
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushReplacementNamed(
          '/booking-confirmation-screen',
          arguments: {
            'mentorData': _mentorData,
            'selectedDate': _selectedDay,
            'selectedTime': _selectedTime,
            'packageName': selectedPackageData['name'],
            'price': 0,
            'isFreeDemo': true,
            'bookingId': 'booking_placeholder',
          },
        );
      } else {
        Navigator.of(context, rootNavigator: true).pushNamed(
          '/payment-screen',
          arguments: {
            'mentorData': _mentorData,
            'selectedDate': _selectedDay,
            'selectedTime': _selectedTime,
            'packageName': selectedPackageData['name'],
            'packageDuration': selectedPackageData['duration'],
            'sessionPrice': selectedPackageData['price'],
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Book Session', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalendarHeaderWidget(mentorData: _mentorData),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Course Package',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        ..._coursePackages.map((package) {
                          final isSelected = _selectedPackage == package['id'];
                          final isFree = package['price'] == 0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.5.h),
                            child: InkWell(
                              onTap: () =>
                                  _onPackageSelected(package['id'] as String),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                      : theme.colorScheme.surface,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.outline,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                package['name'] as String,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              if (package['badge'] != null) ...[
                                                SizedBox(width: 2.w),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 0.3.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isFree
                                                        ? AppTheme.successLight
                                                        : theme
                                                              .colorScheme
                                                              .primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    package['badge'] as String,
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            '${package['duration']} • ${package['description']}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isFree
                                              ? 'FREE'
                                              : '${package['price']} coins',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isFree
                                                    ? AppTheme.successLight
                                                    : theme.colorScheme.primary,
                                              ),
                                        ),
                                        if (!isFree)
                                          Text(
                                            '₹${package['price']}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  MonthCalendarWidget(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                    availableDates: _availableDates,
                  ),
                  _showTimeSlots && _selectedDay != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Available Time Slots',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    DateFormat(
                                      'EEEE, dd MMMM yyyy',
                                    ).format(_selectedDay!),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Column(
                                children: (_timeSlots).map((slot) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 1.5.h),
                                    child: TimeSlotWidget(
                                      time: slot['time'] as String,
                                      isSelected: _selectedTime == slot['time'],
                                      isAvailable: slot['isAvailable'] as bool,
                                      onTap: () => _onTimeSlotSelected(
                                        slot['time'] as String,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: 2.h),
                  const PreparationTipsWidget(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          SessionSummaryWidget(
            selectedDate: _selectedDay,
            selectedTime: _selectedTime,
            selectedPackage: _selectedPackage,
            coursePackages: _coursePackages,
            mentorName: _mentorData['name'] as String,
            isLoading: _isLoading,
            onProceedToPayment: _proceedToPayment,
          ),
        ],
      ),
    );
  }
}