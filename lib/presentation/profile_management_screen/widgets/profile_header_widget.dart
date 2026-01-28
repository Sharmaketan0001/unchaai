import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile header widget displaying user information and photo
class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final String accountCreationDate;
  final String profileImageUrl;
  final bool isSyncing;
  final Function(String) onPhotoUpdate;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.accountCreationDate,
    required this.profileImageUrl,
    required this.isSyncing,
    required this.onPhotoUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Column(
            children: [
              // Title
              Text(
                "Profile",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 3.h),

              // Profile Photo with Camera Overlay
              Stack(
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.onPrimary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: profileImageUrl,
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.cover,
                        semanticLabel: "Profile photo of user",
                      ),
                    ),
                  ),

                  // Camera Icon Overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showPhotoOptions(context),
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Syncing Indicator
                  if (isSyncing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 2.h),

              // User Name
              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 0.5.h),

              // Phone Number
              Text(
                phoneNumber,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 0.5.h),

              // Account Creation Date
              Text(
                accountCreationDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows photo selection options bottom sheet
  void _showPhotoOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  "Update Profile Photo",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                title: Text("Take Photo", style: theme.textTheme.titleMedium),
                subtitle: Text(
                  "Use camera to capture new photo",
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onPhotoUpdate('camera');
                },
              ),
              ListTile(
                leading: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                title: Text(
                  "Choose from Gallery",
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  "Select existing photo from gallery",
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onPhotoUpdate('gallery');
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
