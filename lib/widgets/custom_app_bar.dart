import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Variants for the custom app bar
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with search functionality
  search,

  /// App bar with back button and title
  withBackButton,

  /// Transparent app bar for overlay scenarios
  transparent,

  /// App bar with centered title
  centered,
}

/// A reusable app bar widget for the EdTech mentorship platform.
///
/// This widget provides consistent navigation and branding across screens
/// with support for multiple variants including search, back navigation,
/// and transparent overlays.
///
/// Features:
/// - Clean, minimal design following Material 3 guidelines
/// - Subtle elevation with smooth scroll behavior
/// - Contextual actions and search integration
/// - Platform-appropriate status bar styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text to display in the app bar
  final String? title;

  /// Optional leading widget (typically back button or menu icon)
  final Widget? leading;

  /// List of action widgets displayed on the right side
  final List<Widget>? actions;

  /// Variant of the app bar to display
  final CustomAppBarVariant variant;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// Background color override (optional)
  final Color? backgroundColor;

  /// Callback for search functionality (when variant is search)
  final Function(String)? onSearchChanged;

  /// Search hint text
  final String searchHint;

  /// Whether to automatically add back button when applicable
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.variant = CustomAppBarVariant.standard,
    this.showElevation = true,
    this.backgroundColor,
    this.onSearchChanged,
    this.searchHint = 'Search mentors...',
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine background color
    final bgColor =
        backgroundColor ??
        (variant == CustomAppBarVariant.transparent
            ? Colors.transparent
            : theme.appBarTheme.backgroundColor);

    // Determine foreground color
    final fgColor = variant == CustomAppBarVariant.transparent
        ? Colors.white
        : theme.appBarTheme.foregroundColor;

    // Configure system UI overlay style
    final overlayStyle = variant == CustomAppBarVariant.transparent
        ? SystemUiOverlayStyle.light
        : (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return AppBar(
      systemOverlayStyle: overlayStyle,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: showElevation && variant != CustomAppBarVariant.transparent
          ? 0
          : 0,
      scrolledUnderElevation: showElevation ? 1 : 0,
      centerTitle: variant == CustomAppBarVariant.centered,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, fgColor),
      title: _buildTitle(context, fgColor),
      actions: _buildActions(context, fgColor),
      titleSpacing: leading == null && !automaticallyImplyLeading ? 16 : null,
    );
  }

  /// Builds the leading widget based on variant
  Widget? _buildLeading(BuildContext context, Color? fgColor) {
    if (leading != null) return leading;

    if (variant == CustomAppBarVariant.withBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: fgColor),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Builds the title widget based on variant
  Widget? _buildTitle(BuildContext context, Color? fgColor) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.search:
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: fgColor?.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: fgColor?.withValues(alpha: 0.6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              isDense: true,
            ),
          ),
        );

      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.withBackButton:
      case CustomAppBarVariant.transparent:
      case CustomAppBarVariant.centered:
        return title != null
            ? Text(
                title!,
                style: theme.appBarTheme.titleTextStyle?.copyWith(
                  color: fgColor,
                ),
              )
            : null;
    }
  }

  /// Builds the actions widgets
  List<Widget>? _buildActions(BuildContext context, Color? fgColor) {
    if (actions == null) return null;

    // Apply color to icon buttons in actions
    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: action.onPressed,
          tooltip: action.tooltip,
          color: fgColor,
        );
      }
      return action;
    }).toList();
  }
}
