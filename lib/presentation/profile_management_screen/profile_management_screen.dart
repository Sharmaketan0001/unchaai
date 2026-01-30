import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

import '../../widgets/custom_icon_widget.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';

/// Profile Management Screen enables user account customization and app settings.
///
/// Features:
/// - Profile photo management with camera/gallery options
/// - Account information editing with validation
/// - Notification preferences with granular controls
/// - Payment methods management
/// - Privacy settings and data controls
/// - App preferences (language, theme, accessibility)
/// - Logout functionality with confirmation
class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {

  final bool _isLoading = false;
  bool _isSyncing = false;

  // User data
  String _userName = "Rahul Sharma";
  final String _phoneNumber = "+91 98765 43210";
  String _email = "";
  String _academicBackground = "";
  String _profileImageUrl =
      "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png";
  final String _accountCreationDate = "Member since Jan 2026";

  // Notification settings
  bool _whatsappNotifications = true;
  bool _sessionReminders = true;
  bool _mentorUpdates = true;
  bool _promotionalContent = false;

  // Privacy settings
  bool _profileVisibility = true;
  bool _dataSharing = false;

  // App preferences
  String _selectedLanguage = "English";
  String _selectedTheme = "System Default";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Profile Header
          ProfileHeaderWidget(
            userName: _userName,
            phoneNumber: _phoneNumber,
            accountCreationDate: _accountCreationDate,
            profileImageUrl: _profileImageUrl,
            isSyncing: _isSyncing,
            onPhotoUpdate: _handlePhotoUpdate,
          ),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Account Information Section
                  SettingsSectionWidget(
                    title: "Account Information",
                    items: [
                      SettingsItem(
                        icon: 'person',
                        title: "Full Name",
                        subtitle: _userName,
                        onTap: () => _editAccountField(
                          context,
                          "Full Name",
                          _userName,
                          (value) => setState(() => _userName = value),
                        ),
                      ),
                      SettingsItem(
                        icon: 'email',
                        title: "Email Address",
                        subtitle: _email.isEmpty ? "Add email" : _email,
                        onTap: () => _editAccountField(
                          context,
                          "Email Address",
                          _email,
                          (value) => setState(() => _email = value),
                          isEmail: true,
                        ),
                      ),
                      SettingsItem(
                        icon: 'school',
                        title: "Academic Background",
                        subtitle: _academicBackground.isEmpty
                            ? "Add background"
                            : _academicBackground,
                        onTap: () => _editAccountField(
                          context,
                          "Academic Background",
                          _academicBackground,
                          (value) =>
                              setState(() => _academicBackground = value),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Notification Settings Section
                  SettingsSectionWidget(
                    title: "Notification Settings",
                    items: [
                      SettingsItem(
                        icon: 'chat',
                        title: "WhatsApp Messages",
                        subtitle: "Booking confirmations and updates",
                        trailing: Switch(
                          value: _whatsappNotifications,
                          onChanged: (value) => setState(
                            () => _whatsappNotifications = value,
                          ),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                      SettingsItem(
                        icon: 'notifications',
                        title: "Session Reminders",
                        subtitle: "Get notified before sessions",
                        trailing: Switch(
                          value: _sessionReminders,
                          onChanged: (value) =>
                              setState(() => _sessionReminders = value),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                      SettingsItem(
                        icon: 'person_add',
                        title: "Mentor Updates",
                        subtitle: "New mentors and availability",
                        trailing: Switch(
                          value: _mentorUpdates,
                          onChanged: (value) =>
                              setState(() => _mentorUpdates = value),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                      SettingsItem(
                        icon: 'campaign',
                        title: "Promotional Content",
                        subtitle: "Offers and announcements",
                        trailing: Switch(
                          value: _promotionalContent,
                          onChanged: (value) =>
                              setState(() => _promotionalContent = value),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Payment Methods Section
                  SettingsSectionWidget(
                    title: "Payment Methods",
                    items: [
                      SettingsItem(
                        icon: 'credit_card',
                        title: "Saved Cards",
                        subtitle: "Manage payment cards",
                        onTap: () => _showPaymentMethods(context),
                      ),
                      SettingsItem(
                        icon: 'account_balance',
                        title: "UPI Details",
                        subtitle: "Manage UPI accounts",
                        onTap: () => _showUPIMethods(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Privacy Controls Section
                  SettingsSectionWidget(
                    title: "Privacy Controls",
                    items: [
                      SettingsItem(
                        icon: 'visibility',
                        title: "Profile Visibility",
                        subtitle: "Control who can see your profile",
                        trailing: Switch(
                          value: _profileVisibility,
                          onChanged: (value) =>
                              setState(() => _profileVisibility = value),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                      SettingsItem(
                        icon: 'share',
                        title: "Data Sharing",
                        subtitle: "Share data for better experience",
                        trailing: Switch(
                          value: _dataSharing,
                          onChanged: (value) =>
                              setState(() => _dataSharing = value),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ),
                      SettingsItem(
                        icon: 'delete_forever',
                        title: "Delete Account",
                        subtitle: "Permanently delete your account",
                        onTap: () => _showDeleteAccountDialog(context),
                        isDestructive: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // App Preferences Section
                  SettingsSectionWidget(
                    title: "App Preferences",
                    items: [
                      SettingsItem(
                        icon: 'language',
                        title: "Language",
                        subtitle: _selectedLanguage,
                        onTap: () => _showLanguageSelector(context),
                      ),
                      SettingsItem(
                        icon: 'palette',
                        title: "Theme",
                        subtitle: _selectedTheme,
                        onTap: () => _showThemeSelector(context),
                      ),
                      SettingsItem(
                        icon: 'accessibility',
                        title: "Accessibility",
                        subtitle: "Font size and display options",
                        onTap: () => _showAccessibilitySettings(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Logout Button
                  LogoutButtonWidget(
                    onLogout: () => _showLogoutDialog(context),
                  ),

                  SizedBox(height: 2.h),

                  // Footer Information
                  _buildFooter(theme),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds footer with version and support information
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Text(
            "Version 1.0.0",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _openSupportLink("help"),
                child: Text(
                  "Help Center",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                " • ",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => _openSupportLink("privacy"),
                child: Text(
                  "Privacy Policy",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                " • ",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => _openSupportLink("terms"),
                child: Text(
                  "Terms",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  /// Handles photo update from camera or gallery
  Future<void> _handlePhotoUpdate(String source) async {
    setState(() => _isSyncing = true);

    // Simulate photo upload and processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _profileImageUrl = source == 'camera'
            ? "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png"
            : "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png";
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile photo updated successfully"),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Shows dialog to edit account field
  Future<void> _editAccountField(
    BuildContext context,
    String fieldName,
    String currentValue,
    Function(String) onSave, {
    bool isEmail = false,
  }) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentValue);
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Edit $fieldName", style: theme.textTheme.titleLarge),
          content: TextField(
            controller: controller,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: fieldName,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              if (isEmail && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                setDialogState(() {
                  errorText = emailRegex.hasMatch(value)
                      ? null
                      : "Invalid email format";
                });
              } else {
                setDialogState(() => errorText = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: errorText == null
                  ? () {
                      onSave(controller.text);
                      Navigator.pop(context);
                      _showSaveConfirmation(context);
                    }
                  : null,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows save confirmation message
  void _showSaveConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Changes saved successfully"),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows payment methods bottom sheet
  void _showPaymentMethods(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                "Saved Payment Cards",
                style: theme.textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildPaymentCard(
                    theme,
                    "Visa",
                    "**** 4532",
                    "Expires 12/27",
                  ),
                  SizedBox(height: 2.h),
                  _buildPaymentCard(
                    theme,
                    "Mastercard",
                    "**** 8901",
                    "Expires 08/26",
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Add new card feature coming soon"),
                        ),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text("Add New Card"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds payment card item
  Widget _buildPaymentCard(
    ThemeData theme,
    String type,
    String number,
    String expiry,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'credit_card',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: theme.textTheme.titleMedium),
                SizedBox(height: 0.5.h),
                Text(
                  number,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  expiry,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: CustomIconWidget(
              iconName: 'delete',
              color: theme.colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows UPI methods bottom sheet
  void _showUPIMethods(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text("UPI Accounts", style: theme.textTheme.titleLarge),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildUPIItem(theme, "rahul@paytm", "Paytm"),
                  SizedBox(height: 2.h),
                  _buildUPIItem(theme, "9876543210@ybl", "PhonePe"),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Add UPI feature coming soon")),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text("Add UPI Account"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds UPI item
  Widget _buildUPIItem(ThemeData theme, String upiId, String provider) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'account_balance',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider, style: theme.textTheme.titleMedium),
                SizedBox(height: 0.5.h),
                Text(
                  upiId,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: CustomIconWidget(
              iconName: 'delete',
              color: theme.colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows language selector dialog
  void _showLanguageSelector(BuildContext context) {
    final theme = Theme.of(context);
    final languages = ["English", "हिन्दी", "मराठी", "தமிழ்", "తెలుగు"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Language", style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                    _showSaveConfirmation(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Shows theme selector dialog
  void _showThemeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final themes = ["System Default", "Light", "Dark"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Theme", style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes
              .map(
                (themeOption) => RadioListTile<String>(
                  title: Text(themeOption),
                  value: themeOption,
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    Navigator.pop(context);
                    _showSaveConfirmation(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Shows accessibility settings dialog
  void _showAccessibilitySettings(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Accessibility Settings",
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Font Size", style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            Slider(
              value: 1.0,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: "Normal",
              onChanged: (value) {},
            ),
            SizedBox(height: 2.h),
            SwitchListTile(
              title: Text("High Contrast"),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text("Reduce Motion"),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Shows delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete your account?",
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: 2.h),
            Text(
              "This action cannot be undone. All your data including:",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "• Booking history\n• Payment information\n• Profile data\n• Session records",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "will be permanently deleted.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Account deletion requires email verification"),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: theme.textTheme.titleLarge),
        content: Text(
          "Are you sure you want to logout?",
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                '/authentication-screen',
                (route) => false,
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  /// Opens support links
  void _openSupportLink(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Opening ${type == 'help'
              ? 'Help Center'
              : type == 'privacy'
              ? 'Privacy Policy'
              : 'Terms of Service'}...",
        ),
      ),
    );
  }
}

/// Settings item model
class SettingsItem {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });
}
