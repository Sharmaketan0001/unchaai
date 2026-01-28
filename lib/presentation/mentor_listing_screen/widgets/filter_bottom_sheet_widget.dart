import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Filter bottom sheet widget with collapsible sections
///
/// Features:
/// - Subject categories filter
/// - Experience level filter
/// - Rating threshold filter
/// - Price range filter
/// - Availability timeframes filter
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.activeFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _categories = [
    'Data Science',
    'Web Development',
    'Mobile Development',
    'UI/UX Design',
    'Digital Marketing',
    'Cloud Computing',
    'Cybersecurity',
    'Business Analytics',
    'Content Writing',
    'Blockchain',
  ];

  final List<String> _experienceLevels = [
    'Entry (0-2 years)',
    'Mid (3-5 years)',
    'Senior (6-10 years)',
    'Expert (10+ years)',
  ];

  final List<String> _availabilityOptions = [
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text('Filters', style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = {
                        'categories': <String>[],
                        'experienceLevel': <String>[],
                        'minRating': 0.0,
                        'priceRange': const RangeValues(0, 10000),
                        'availability': <String>[],
                      };
                    });
                  },
                  child: Text(
                    'Reset',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter sections
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildFilterSection(
                    'Subject Categories',
                    _buildCategoryChips(theme),
                    theme,
                  ),

                  SizedBox(height: 3.h),

                  // Experience Level
                  _buildFilterSection(
                    'Experience Level',
                    _buildExperienceChips(theme),
                    theme,
                  ),

                  SizedBox(height: 3.h),

                  // Rating
                  _buildFilterSection(
                    'Minimum Rating',
                    _buildRatingSlider(theme),
                    theme,
                  ),

                  SizedBox(height: 3.h),

                  // Price Range
                  _buildFilterSection(
                    'Price Range (₹/hour)',
                    _buildPriceRangeSlider(theme),
                    theme,
                  ),

                  SizedBox(height: 3.h),

                  // Availability
                  _buildFilterSection(
                    'Availability',
                    _buildAvailabilityChips(theme),
                    theme,
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        content,
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _categories.map((category) {
        final isSelected = (_filters['categories'] as List).contains(category);

        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                (_filters['categories'] as List).add(category);
              } else {
                (_filters['categories'] as List).remove(category);
              }
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _experienceLevels.map((level) {
        final isSelected = (_filters['experienceLevel'] as List).contains(
          level,
        );

        return FilterChip(
          label: Text(level),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                (_filters['experienceLevel'] as List).add(level);
              } else {
                (_filters['experienceLevel'] as List).remove(level);
              }
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSlider(ThemeData theme) {
    final minRating = _filters['minRating'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(iconName: 'star', color: Colors.amber, size: 20),
            SizedBox(width: 2.w),
            Text(
              minRating > 0 ? '${minRating.toStringAsFixed(1)}+' : 'Any rating',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: minRating > 0 ? minRating.toStringAsFixed(1) : 'Any',
          onChanged: (value) {
            setState(() {
              _filters['minRating'] = value;
            });
          },
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.outline,
        ),
      ],
    );
  }

  Widget _buildPriceRangeSlider(ThemeData theme) {
    final priceRange = _filters['priceRange'] as RangeValues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${priceRange.start.toInt()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₹${priceRange.end.toInt()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 10000,
          divisions: 20,
          labels: RangeLabels(
            '₹${priceRange.start.toInt()}',
            '₹${priceRange.end.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _filters['priceRange'] = values;
            });
          },
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.outline,
        ),
      ],
    );
  }

  Widget _buildAvailabilityChips(ThemeData theme) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _availabilityOptions.map((option) {
        final isSelected = (_filters['availability'] as List).contains(option);

        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                (_filters['availability'] as List).add(option);
              } else {
                (_filters['availability'] as List).remove(option);
              }
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        );
      }).toList(),
    );
  }
}
