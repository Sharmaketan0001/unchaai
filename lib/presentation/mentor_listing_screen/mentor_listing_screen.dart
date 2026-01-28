import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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

  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _filteredMentors = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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

    // Simulate API call - Replace with actual Firestore query
    await Future.delayed(const Duration(seconds: 1));

    final mentors = [
      {
        "id": "1",
        "name": "Dr. Priya Sharma",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_117f9c471-1763300920090.png",
        "semanticLabel":
            "Professional woman with long dark hair wearing glasses and business attire",
        "expertise": ["Data Science", "Machine Learning", "Python"],
        "experience": 8,
        "rating": 4.9,
        "reviewCount": 156,
        "hourlyRate": 1500,
        "availability": "Available Today",
        "isAvailable": true,
        "bio":
            "PhD in Computer Science with 8+ years of industry experience in AI/ML",
        "isFavorite": false,
      },
      {
        "id": "2",
        "name": "Rajesh Kumar",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_10ffc0fb5-1763299748785.png",
        "semanticLabel":
            "Professional man with short black hair wearing blue shirt and smiling",
        "expertise": ["Web Development", "React", "Node.js"],
        "experience": 6,
        "rating": 4.8,
        "reviewCount": 142,
        "hourlyRate": 1200,
        "availability": "Available Tomorrow",
        "isAvailable": true,
        "bio": "Full-stack developer specializing in modern web technologies",
        "isFavorite": false,
      },
      {
        "id": "3",
        "name": "Ananya Desai",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_128683b30-1763296674609.png",
        "semanticLabel":
            "Young woman with shoulder-length brown hair wearing casual attire",
        "expertise": ["Digital Marketing", "SEO", "Content Strategy"],
        "experience": 5,
        "rating": 4.7,
        "reviewCount": 98,
        "hourlyRate": 1000,
        "availability": "Available This Week",
        "isAvailable": true,
        "bio":
            "Marketing strategist with proven track record in digital campaigns",
        "isFavorite": false,
      },
      {
        "id": "4",
        "name": "Vikram Singh",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_18a65e4f0-1763293568983.png",
        "semanticLabel":
            "Professional man with beard wearing formal shirt outdoors",
        "expertise": ["Mobile Development", "Flutter", "iOS"],
        "experience": 7,
        "rating": 4.9,
        "reviewCount": 178,
        "hourlyRate": 1400,
        "availability": "Available Today",
        "isAvailable": true,
        "bio":
            "Senior mobile developer with expertise in cross-platform solutions",
        "isFavorite": false,
      },
      {
        "id": "5",
        "name": "Meera Patel",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_13b401b81-1763293456584.png",
        "semanticLabel":
            "Woman with long dark hair wearing professional attire and smiling",
        "expertise": ["UI/UX Design", "Figma", "Product Design"],
        "experience": 4,
        "rating": 4.8,
        "reviewCount": 112,
        "hourlyRate": 1100,
        "availability": "Available Tomorrow",
        "isAvailable": true,
        "bio": "Product designer focused on user-centered design solutions",
        "isFavorite": false,
      },
      {
        "id": "6",
        "name": "Arjun Reddy",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1404a20cb-1763293681238.png",
        "semanticLabel":
            "Young man with short hair wearing casual shirt outdoors",
        "expertise": ["Cloud Computing", "AWS", "DevOps"],
        "experience": 9,
        "rating": 4.9,
        "reviewCount": 203,
        "hourlyRate": 1600,
        "availability": "Available Today",
        "isAvailable": true,
        "bio":
            "Cloud architect with extensive experience in scalable infrastructure",
        "isFavorite": false,
      },
      {
        "id": "7",
        "name": "Kavya Iyer",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_19a5467f2-1763301182950.png",
        "semanticLabel":
            "Professional woman with glasses and dark hair in business setting",
        "expertise": ["Business Analytics", "Tableau", "SQL"],
        "experience": 6,
        "rating": 4.7,
        "reviewCount": 134,
        "hourlyRate": 1250,
        "availability": "Available This Week",
        "isAvailable": true,
        "bio": "Data analyst helping businesses make data-driven decisions",
        "isFavorite": false,
      },
      {
        "id": "8",
        "name": "Siddharth Joshi",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1c583d45e-1763293763846.png",
        "semanticLabel":
            "Man with short dark hair wearing casual attire and smiling",
        "expertise": ["Cybersecurity", "Ethical Hacking", "Network Security"],
        "experience": 10,
        "rating": 4.9,
        "reviewCount": 189,
        "hourlyRate": 1700,
        "availability": "Available Tomorrow",
        "isAvailable": true,
        "bio": "Cybersecurity expert with certifications in ethical hacking",
        "isFavorite": false,
      },
      {
        "id": "9",
        "name": "Nisha Gupta",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f3387869-1763301386730.png",
        "semanticLabel":
            "Young woman with long hair wearing professional attire",
        "expertise": ["Content Writing", "Copywriting", "SEO Writing"],
        "experience": 3,
        "rating": 4.6,
        "reviewCount": 87,
        "hourlyRate": 900,
        "availability": "Available Today",
        "isAvailable": true,
        "bio": "Creative writer specializing in engaging digital content",
        "isFavorite": false,
      },
      {
        "id": "10",
        "name": "Aditya Verma",
        "photo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_12c1d7f8f-1763294585737.png",
        "semanticLabel": "Professional man with beard wearing formal attire",
        "expertise": ["Blockchain", "Cryptocurrency", "Smart Contracts"],
        "experience": 5,
        "rating": 4.8,
        "reviewCount": 145,
        "hourlyRate": 1350,
        "availability": "Available This Week",
        "isAvailable": true,
        "bio":
            "Blockchain developer with expertise in decentralized applications",
        "isFavorite": false,
      },
    ];

    setState(() {
      _mentors = mentors;
      _filteredMentors = mentors.take(_itemsPerPage).toList();
      _isLoading = false;
    });
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
    List<Map<String, dynamic>> filtered = List.from(_mentors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((mentor) {
        final name = (mentor['name'] as String).toLowerCase();
        final expertise = (mentor['expertise'] as List).join(' ').toLowerCase();
        return name.contains(_searchQuery) || expertise.contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if ((_activeFilters['categories'] as List).isNotEmpty) {
      filtered = filtered.where((mentor) {
        final mentorExpertise = mentor['expertise'] as List;
        return (_activeFilters['categories'] as List).any(
          (category) => mentorExpertise.any(
            (exp) => (exp as String).toLowerCase().contains(
              (category as String).toLowerCase(),
            ),
          ),
        );
      }).toList();
    }

    // Apply experience filter
    if ((_activeFilters['experienceLevel'] as List).isNotEmpty) {
      filtered = filtered.where((mentor) {
        final experience = mentor['experience'] as int;
        final levels = _activeFilters['experienceLevel'] as List;

        if (levels.contains('Entry (0-2 years)') && experience <= 2) {
          return true;
        }
        if (levels.contains('Mid (3-5 years)') &&
            experience >= 3 &&
            experience <= 5) {
          return true;
        }
        if (levels.contains('Senior (6-10 years)') &&
            experience >= 6 &&
            experience <= 10) {
          return true;
        }
        if (levels.contains('Expert (10+ years)') && experience > 10) {
          return true;
        }

        return false;
      }).toList();
    }

    // Apply rating filter
    final minRating = _activeFilters['minRating'] as double;
    if (minRating > 0) {
      filtered = filtered
          .where((mentor) => (mentor['rating'] as double) >= minRating)
          .toList();
    }

    // Apply price range filter
    final priceRange = _activeFilters['priceRange'] as RangeValues;
    filtered = filtered.where((mentor) {
      final rate = mentor['hourlyRate'] as int;
      return rate >= priceRange.start && rate <= priceRange.end;
    }).toList();

    // Apply availability filter
    if ((_activeFilters['availability'] as List).isNotEmpty) {
      filtered = filtered.where((mentor) {
        final availability = mentor['availability'] as String;
        return (_activeFilters['availability'] as List).any(
          (filter) => availability.contains(filter as String),
        );
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return (b['rating'] as double).compareTo(a['rating'] as double);
        case 'price':
          return (a['hourlyRate'] as int).compareTo(b['hourlyRate'] as int);
        case 'experience':
          return (b['experience'] as int).compareTo(a['experience'] as int);
        case 'availability':
          final aAvailable = a['isAvailable'] as bool;
          final bAvailable = b['isAvailable'] as bool;
          if (aAvailable == bAvailable) return 0;
          return aAvailable ? -1 : 1;
        default:
          return 0;
      }
    });

    setState(() {
      _filteredMentors = filtered.take(_itemsPerPage).toList();
      _currentPage = 1;
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
