import 'package:flutter/material.dart';

/// A reusable bottom navigation bar widget for the EdTech mentorship platform.
///
/// This widget provides thumb-reachable navigation for core features:
/// - Home/Dashboard: Central hub for mentor discovery and session overview
/// - My Sessions: Active session management and meeting access
/// - Profile: Account settings and preferences
///
/// The widget is parameterized to allow flexible usage across different
/// implementations while maintaining consistent design and behavior.
class CustomBottomBar extends StatelessWidget {
  /// The currently selected tab index
  final int currentIndex;

  /// Callback function triggered when a navigation item is tapped
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
          unselectedLabelStyle:
              theme.bottomNavigationBarTheme.unselectedLabelStyle,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home, size: 24),
              ),
              label: 'Home',
              tooltip: 'Home Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today, size: 24),
              ),
              label: 'Sessions',
              tooltip: 'My Sessions',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline, size: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 24),
              ),
              label: 'Profile',
              tooltip: 'Profile Management',
            ),
          ],
        ),
      ),
    );
  }
}
