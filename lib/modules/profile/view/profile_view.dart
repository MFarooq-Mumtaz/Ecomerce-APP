import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Obx(() {
            switch (controller.status.value) {
              case ProfileLoadStatus.idle:
              case ProfileLoadStatus.loading:
                return const AppLoadingState(message: 'Loading profile');
              case ProfileLoadStatus.error:
                return AppErrorState(
                  message:
                      controller.errorMessage.value ??
                      'Profile could not be loaded.',
                  onRetry: controller.loadProfile,
                );
              case ProfileLoadStatus.success:
                final profile = controller.user.value;
                if (profile == null) {
                  return const AppEmptyState(
                    title: 'Profile unavailable',
                    message: 'Sign in again to load your profile.',
                    icon: Icons.person_outline,
                  );
                }

                return ResponsiveBuilder(
                  builder: (context, layout) => CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: layout.pageInsets(
                          top: layout.height < 560 ? 16 : 44,
                          bottom: 0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Profile',
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: layout.pageInsets(top: 24),
                        sliver: SliverList.list(
                          children: [
                            _ProfileHeader(
                              displayName: profile.displayName.trim().isEmpty
                                  ? profile.email.split('@').first
                                  : profile.displayName.trim(),
                              email: profile.email,
                              photoUrl: controller.previewPhotoUrl,
                              isPickingPhoto: controller.isPickingPhoto.value,
                              onPickPhoto: controller.pickProfilePhoto,
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: controller.displayNameController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Display name',
                              ),
                              onSubmitted: (_) => controller.saveDisplayName(),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: AppLayout.buttonHeight,
                              child: Obx(
                                () => FilledButton(
                                  onPressed: controller.isSaving.value
                                      ? null
                                      : controller.saveDisplayName,
                                  child: controller.isSaving.value
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Save Profile'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ProfileMenuItem(
                              icon: Icons.favorite_border,
                              title: 'Wishlist',
                              subtitle: 'Saved products',
                              onTap: () => Get.toNamed(AppRoutes.wishlist),
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final isVendor =
                                  controller.user.value?.isVendor ?? false;
                              if (isVendor) {
                                return _ProfileMenuItem(
                                  icon: Icons.storefront_outlined,
                                  title: 'Manage Store',
                                  subtitle: 'Open vendor dashboard',
                                  onTap: () =>
                                      Get.toNamed(AppRoutes.vendorDashboard),
                                );
                              }

                              return _ProfileMenuItem(
                                icon: Icons.storefront_outlined,
                                title: 'Become a Vendor',
                                subtitle: 'Create your store profile',
                                onTap: () =>
                                    Get.toNamed(AppRoutes.becomeVendor),
                              );
                            }),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: AppLayout.buttonHeight,
                              child: Obx(
                                () => OutlinedButton.icon(
                                  onPressed:
                                      controller.isLoggingOut.value ||
                                          controller.isDeletingAccount.value
                                      ? null
                                      : controller.logout,
                                  icon: controller.isLoggingOut.value
                                      ? const SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.logout),
                                  label: const Text('Logout'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: AppLayout.buttonHeight,
                              child: Obx(
                                () => OutlinedButton.icon(
                                  onPressed: controller.isDeletingAccount.value
                                      ? null
                                      : controller.confirmDeleteAccount,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  icon: controller.isDeletingAccount.value
                                      ? const SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                  label: const Text('Delete Account'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
            }
          }),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.isPickingPhoto,
    required this.onPickPhoto,
    this.photoUrl,
  });

  final String displayName;
  final String email;
  final bool isPickingPhoto;
  final VoidCallback onPickPhoto;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProfilePhotoButton(
          photoUrl: photoUrl,
          isPickingPhoto: isPickingPhoto,
          onPickPhoto: onPickPhoto,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePhotoButton extends StatelessWidget {
  const _ProfilePhotoButton({
    required this.isPickingPhoto,
    required this.onPickPhoto,
    this.photoUrl,
  });

  final String? photoUrl;
  final bool isPickingPhoto;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider(photoUrl);

    return Semantics(
      button: true,
      label: 'Edit profile photo',
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: isPickingPhoto ? null : onPickPhoto,
        child: SizedBox.square(
          dimension: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: context.colors.surface,
                  foregroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person_outline, size: 30)
                      : null,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.background,
                      width: 2,
                    ),
                  ),
                  child: isPickingPhoto
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _imageProvider(String? value) {
    final photo = value?.trim();
    if (photo == null || photo.isEmpty) {
      return null;
    }

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return NetworkImage(photo);
    }

    final file = File(photo);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        onTap: onTap,
        enabled: onTap != null,
        leading: CircleAvatar(
          backgroundColor: context.colors.background,
          foregroundColor: context.colors.textPrimary,
          child: Icon(icon),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        trailing: onTap == null
            ? const Icon(Icons.hourglass_empty)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
