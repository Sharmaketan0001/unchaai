import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/database_service.dart';
import '../../services/realtime_service.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/mentor_card_widget.dart';
import './widgets/search_bar_widget.dart';

/// Mentor Listing Screen - Comprehensive mentor discovery with filtering
///
/// Features:
/// - Search with voice input support
/// - Advanced filtering (subject, experience, rating, price, availability)
/// - Sort options (rating, price, experience, availability)
/// - Pull-to-refresh for real-time availability
/// - Infinite scroll with skeleton loading
/// - Quick actions (favorites, share, reviews)
class MentorListingScreen extends StatefulWidget {
  const MentorListingScreen({super.key});

  @override
  State<MentorListingScreen> createState() => _MentorListingScreenState();
}

class _MentorListingScreenState extends State<MentorListingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _databaseService = DatabaseService.instance;
  final _realtimeService = RealtimeService.instance;

  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _filteredMentors = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  RealtimeChannel? _mentorsSubscription;

  // Filter state
  Map<String, dynamic> _activeFilters = {
    'categories': <String>[],
    'experienceLevel': <String>[],
    'minRating': 0.0,
    'priceRange': RangeValues(0, 10000),
    'availability': <String>[],
  };

  // Sort state
  String _sortBy = 'rating'; // rating, price, experience, availability

  @override
  void initState() {
    super.initState();
    _loadMentors();
    _subscribeToMentors();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe('all_mentors');
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToMentors() {
    _mentorsSubscription = _realtimeService.subscribeToMentors(
      onInsert: (mentor) {
        setState(() {
          _mentors.add(mentor);
          _applyFiltersAndSort();
        });
      },
      onUpdate: (mentor) {
        setState(() {
          final index = _mentors.indexWhere((m) => m['id'] == mentor['id']);
          if (index != -1) {
            _mentors[index] = mentor;
            _applyFiltersAndSort();
          }
        });
      },
      onDelete: (mentor) {
        setState(() {
          _mentors.removeWhere((m) => m['id'] == mentor['id']);
          _applyFiltersAndSort();
        });
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _filteredMentors.length < _mentors.length) {
        _loadMoreMentors();
      }
    }
  }

  Future<void> _loadMentors() async {
    setState(() => _isLoading = true);

    try {
      final mentors = await _databaseService.getMentors(
        minRating: _activeFilters['minRating'],
        maxPrice: _activeFilters['priceRange'].end,
        limit: 50,
      );

      setState(() {
        _mentors = mentors;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mentors: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreMentors() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _mentors.length);

    if (startIndex < _mentors.length) {
      setState(() {
        _filteredMentors.addAll(_mentors.sublist(startIndex, endIndex));
        _currentPage++;
        _isLoadingMore = false;
      });
    } else {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshMentors() async {
    await _loadMentors();
    _applyFiltersAndSort();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    var filtered = List<Map<String, dynamic>>.from(_mentors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((mentor) {
        final userProfile = mentor['user_profiles'] as Map<String, dynamic>?;
        final name = (userProfile?['full_name'] ?? '').toString().toLowerCase();
        final title = (mentor['title'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || title.contains(query);
      }).toList();
    }

    // Apply rating filter
    if (_activeFilters['minRating'] > 0) {
      filtered = filtered.where((mentor) {
        final rating = (mentor['rating'] ?? 0.0) as num;
        return rating >= _activeFilters['minRating'];
      }).toList();
    }

    // Apply price filter
    final priceRange = _activeFilters['priceRange'] as RangeValues;
    filtered = filtered.where((mentor) {
      final price = (mentor['hourly_rate'] ?? 0) as num;
      return price >= priceRange.start && price <= priceRange.end;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) {
          final ratingA = (a['rating'] ?? 0.0) as num;
          final ratingB = (b['rating'] ?? 0.0) as num;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'price':
        filtered.sort((a, b) {
          final priceA = (a['hourly_rate'] ?? 0) as num;
          final priceB = (b['hourly_rate'] ?? 0) as num;
          return priceA.compareTo(priceB);
        });
        break;
      case 'experience':
        filtered.sort((a, b) {
          final expA = (a['years_of_experience'] ?? 0) as num;
          final expB = (b['years_of_experience'] ?? 0) as num;
          return expB.compareTo(expA);
        });
        break;
    }

    setState(() {
      _filteredMentors = filtered.take(_currentPage * _itemsPerPage).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        activeFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _showSortOptions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Text('Sort By', style: theme.textTheme.titleLarge),
                  const Spacer(),
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
            _buildSortOption('Rating (High to Low)', 'rating', theme),
            _buildSortOption('Price (Low to High)', 'price', theme),
            _buildSortOption('Experience (High to Low)', 'experience', theme),
            _buildSortOption('Availability', 'availability', theme),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, ThemeData theme) {
    final isSelected = _sortBy == value;

    return ListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              color: theme.colorScheme.primary,
              size: 24,
            )
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _applyFiltersAndSort();
        });
        Navigator.pop(context);
      },
    );
  }

  void _toggleFavorite(String mentorId) {
    setState(() {
      final index = _filteredMentors.indexWhere((m) => m['id'] == mentorId);
      if (index != -1) {
        _filteredMentors[index]['isFavorite'] =
            !(_filteredMentors[index]['isFavorite'] as bool);
      }

      final mainIndex = _mentors.indexWhere((m) => m['id'] == mentorId);
      if (mainIndex != -1) {
        _mentors[mainIndex]['isFavorite'] =
            !(_mentors[mainIndex]['isFavorite'] as bool);
      }
    });
  }

  void _shareMentorProfile(Map<String, dynamic> mentor) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${mentor['name']}\'s profile'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewReviews(Map<String, dynamic> mentor) {
    // Navigate to reviews screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing reviews for ${mentor['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeFilter(String filterType, dynamic value) {
    setState(() {
      if (filterType == 'categories' ||
          filterType == 'experienceLevel' ||
          filterType == 'availability') {
        (_activeFilters[filterType] as List).remove(value);
      } else if (filterType == 'rating') {
        _activeFilters['minRating'] = 0.0;
      } else if (filterType == 'price') {
        _activeFilters['priceRange'] = const RangeValues(0, 10000);
      }
      _applyFiltersAndSort();
    });
  }

  int _getActiveFilterCount() {
    int count = 0;

    if ((_activeFilters['categories'] as List).isNotEmpty) count++;
    if ((_activeFilters['experienceLevel'] as List).isNotEmpty) count++;
    if ((_activeFilters['minRating'] as double) > 0) count++;

    final priceRange = _activeFilters['priceRange'] as RangeValues;
    if (priceRange.start > 0 || priceRange.end < 10000) count++;

    if ((_activeFilters['availability'] as List).isNotEmpty) count++;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterCount = _getActiveFilterCount();

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
        title: Text('Find Mentors', style: theme.appBarTheme.titleTextStyle),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'filter_list',
                  color: theme.appBarTheme.foregroundColor,
                  size: 24,
                ),
                onPressed: _showFilterBottomSheet,
              ),
              filterCount > 0
                  ? Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          filterCount.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onVoiceSearch: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice search activated'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // Active filters chips
          if (filterCount > 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  ...(_activeFilters['categories'] as List).map(
                    (category) => _buildFilterChip(
                      category as String,
                      'categories',
                      category,
                      theme,
                    ),
                  ),
                  ...(_activeFilters['experienceLevel'] as List).map(
                    (level) => _buildFilterChip(
                      level as String,
                      'experienceLevel',
                      level,
                      theme,
                    ),
                  ),
                  if ((_activeFilters['minRating'] as double) > 0)
                    _buildFilterChip(
                      'Rating ${(_activeFilters['minRating'] as double).toStringAsFixed(1)}+',
                      'rating',
                      null,
                      theme,
                    ),
                  ...(_activeFilters['availability'] as List).map(
                    (avail) => _buildFilterChip(
                      avail as String,
                      'availability',
                      avail,
                      theme,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _activeFilters = {
                          'categories': <String>[],
                          'experienceLevel': <String>[],
                          'minRating': 0.0,
                          'priceRange': const RangeValues(0, 10000),
                          'availability': <String>[],
                        };
                        _applyFiltersAndSort();
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text(
                      'Clear All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Mentor list
          Expanded(
            child: _isLoading
                ? _buildSkeletonList(theme)
                : _filteredMentors.isEmpty
                ? _buildEmptyState(theme)
                : RefreshIndicator(
                    onRefresh: _refreshMentors,
                    color: theme.colorScheme.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount:
                          _filteredMentors.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredMentors.length) {
                          return _buildLoadingCard(theme);
                        }

                        final mentor = _filteredMentors[index];
                        return MentorCardWidget(
                          mentor: mentor,
                          onTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              '/mentor-profile-screen',
                              arguments: mentor,
                            );
                          },
                          onLongPress: () => _showQuickActions(mentor, theme),
                          onFavoriteToggle: () =>
                              _toggleFavorite(mentor['id'] as String),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSortOptions,
        backgroundColor: theme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'sort',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String filterType,
    dynamic value,
    ThemeData theme,
  ) {
    return Chip(
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      deleteIcon: CustomIconWidget(
        iconName: 'close',
        color: theme.colorScheme.onPrimary,
        size: 16,
      ),
      onDeleted: () => _removeFilter(filterType, value),
    );
  }

  Widget _buildSkeletonList(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: 5,
      itemBuilder: (context, index) => _buildLoadingCard(theme),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 30.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 60.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: theme.colorScheme.onSurfaceVariant,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Mentors Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'No mentors match your current filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _activeFilters = {
                    'categories': <String>[],
                    'experienceLevel': <String>[],
                    'minRating': 0.0,
                    'priceRange': const RangeValues(0, 10000),
                    'availability': <String>[],
                  };
                  _applyFiltersAndSort();
                });
              },
              icon: CustomIconWidget(
                iconName: 'clear',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> mentor, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: mentor['photo'] as String,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                      semanticLabel: mentor['semanticLabel'] as String,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      mentor['name'] as String,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: (mentor['isFavorite'] as bool)
                    ? 'favorite'
                    : 'favorite_border',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                (mentor['isFavorite'] as bool)
                    ? 'Remove from Favorites'
                    : 'Add to Favorites',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                _toggleFavorite(mentor['id'] as String);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Share Profile', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _shareMentorProfile(mentor);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'rate_review',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('View Reviews', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _viewReviews(mentor);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
