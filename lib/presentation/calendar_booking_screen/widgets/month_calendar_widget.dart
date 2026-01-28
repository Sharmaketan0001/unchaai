import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Interactive monthly calendar with availability indicators
class MonthCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<DateTime> availableDates;

  const MonthCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.availableDates,
  });

  bool _isDateAvailable(DateTime date) {
    return availableDates.any(
      (availableDate) => isSameDay(availableDate, date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (_isDateAvailable(selectedDay)) {
            onDaySelected(selectedDay, focusedDay);
          }
        },
        onPageChanged: onPageChanged,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: CustomIconWidget(
            iconName: 'chevron_left',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          rightChevronIcon: CustomIconWidget(
            iconName: 'chevron_right',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.all(1.w),
          defaultDecoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          weekendDecoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          outsideDecoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          disabledDecoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          disabledTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final isAvailable = _isDateAvailable(day);
            return Container(
              margin: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: isAvailable
                    ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: isAvailable
                    ? Border.all(
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: isAvailable
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                    fontWeight: isAvailable ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
