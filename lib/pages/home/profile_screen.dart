import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/settings/homeu_language_controller.dart';
import 'package:homeu/app/settings/homeu_theme_controller.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/auth/login_screen.dart';
import 'package:homeu/pages/home/favorites_screen.dart';
import 'package:homeu/pages/home/update_password_screen.dart';

class HomeUProfileScreen extends StatefulWidget {
  const HomeUProfileScreen({
    super.key,
    required this.role,
    this.profileController,
  });

  final HomeURole role;

  final HomeUProfileController? profileController;

  @override
  State<HomeUProfileScreen> createState() => _HomeUProfileScreenState();
}

class _HomeUProfileScreenState extends State<HomeUProfileScreen> {
  late final HomeUProfileController _profileController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _localAvatarPath;
  int _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    final authService = HomeUAuthService.instance;
    final userId = authService.currentUserId ?? '';
    final initialProfile = HomeUProfileData(
      userId: userId,
      fullName: '',
      email: authService.currentSession?.user.email ?? '',
      phoneNumber: '',
      role: widget.role,
    );

    _profileController =
        widget.profileController ??
        HomeUProfileController(initialProfile: initialProfile);
    _profileController.loadProfile();
  }

  @override
  void dispose() {
    if (widget.profileController == null) {
      _profileController.dispose();
    }
    super.dispose();
  }

  Future<void> _openEditProfileSheet(HomeUProfileData profile) async {
    final input = await showModalBottomSheet<_EditProfileInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile),
    );

    if (!mounted) {
      return;
    }

    if (input == null) {
      return;
    }

    if (input.fullName.isEmpty || input.phoneNumber.isEmpty) {
      _showProfileFeedback(context.l10n.profileNamePhoneRequired);
      return;
    }

    final updated = await _profileController.updateProfile(
      fullName: input.fullName,
      phoneNumber: input.phoneNumber,
      profileImageUrl: _profileController.profile.profileImageUrl,
    );

    if (!mounted) {
      return;
    }

    if (updated) {
      _showProfileFeedback(context.l10n.profileUpdatedSuccess);
    } else if (_profileController.errorMessage != null) {
      _showProfileFeedback(_resolveProfileMessage(_profileController.errorMessage!));
    }
  }

  void _showProfileFeedback(String message) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> _editAvatar() async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.homeuCard,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1F1E3A8A),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(context.l10n.profilePhotoChooseGallery),
                  subtitle: Text(
                    context.l10n.profilePhotoChooseGallerySubtitle,
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_AvatarAction.gallery),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1F1E3A8A),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(context.l10n.profilePhotoTakeCamera),
                  subtitle: Text(context.l10n.profilePhotoTakeCameraSubtitle),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_AvatarAction.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == _AvatarAction.gallery || action == _AvatarAction.camera) {
      final source = action == _AvatarAction.gallery
          ? ImageSource.gallery
          : ImageSource.camera;
      await _pickAvatarImage(source);
    }
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (!mounted || pickedFile == null) {
        return;
      }

      final previousLocalAvatarPath = _localAvatarPath;
      final previousRemoteAvatarUrl =
          _profileController.profile.profileImageUrl?.trim();

      setState(() {
        _localAvatarPath = pickedFile.path;
      });

      final uploaded = await _profileController.uploadAvatar(
        imagePath: pickedFile.path,
      );
      if (!mounted) {
        return;
      }

      if (uploaded) {
        // Force the old avatar key out of the in-memory cache before rendering.
        if (previousRemoteAvatarUrl != null && previousRemoteAvatarUrl.isNotEmpty) {
          await NetworkImage(previousRemoteAvatarUrl).evict();
        }

        setState(() {
          // Persisted URL from Supabase profile now becomes the source of truth.
          _localAvatarPath = null;
          _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch;
        });
        _showProfileFeedback(context.l10n.profilePhotoUpdatedSuccess);
      } else {
        setState(() {
          _localAvatarPath = previousLocalAvatarPath;
        });
        _showProfileFeedback(
          _profileController.errorMessage != null
              ? _resolveProfileMessage(_profileController.errorMessage!)
              : context.l10n.profileErrorUpload,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showProfileFeedback(context.l10n.profilePhotoAccessError);
    }
  }

  String _languageLabel(BuildContext context, String code) {
    final t = context.l10n;
    switch (code) {
      case 'ms':
        return t.languageMalay;
      case 'zh':
        return t.languageChinese;
      case 'en':
      default:
        return t.languageEnglish;
    }
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    final t = context.l10n;
    switch (mode) {
      case ThemeMode.light:
        return t.themeLight;
      case ThemeMode.dark:
        return t.themeDark;
      case ThemeMode.system:
        return t.themeSystem;
    }
  }

  Future<void> _openThemeSheet() async {
    final currentMode = HomeUThemeController.instance.themeMode;
    final selectedMode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.homeuCard,
      builder: (sheetContext) {
        final options = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (mode) => ListTile(
                    leading: Icon(
                      mode == currentMode
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: mode == currentMode
                          ? context.homeuAccent
                          : context.homeuMutedText,
                    ),
                    title: Text(_themeLabel(context, mode)),
                    onTap: () => Navigator.of(sheetContext).pop(mode),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (!mounted || selectedMode == null || selectedMode == currentMode) {
      return;
    }

    await HomeUThemeController.instance.setPreferredThemeMode(selectedMode);
    if (!mounted) {
      return;
    }
    _showProfileFeedback(context.l10n.profileThemeSaved);
  }

  Future<void> _openLanguageSheet() async {
    final currentCode = _profileController.selectedLanguageCode;
    final selectedCode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.homeuCard,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const ['en', 'ms', 'zh']
                .map(
                  (code) => ListTile(
                    leading: Icon(
                      code == currentCode
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: code == currentCode
                          ? context.homeuAccent
                          : context.homeuMutedText,
                    ),
                    title: Text(_languageLabel(context, code)),
                    onTap: () => Navigator.of(sheetContext).pop(code),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (!mounted || selectedCode == null || selectedCode == currentCode) {
      return;
    }

    final updated = await _profileController.updateLanguagePreference(
      selectedCode,
    );
    if (!mounted) {
      return;
    }

    if (updated) {
      HomeULanguageController.instance.setLocalLanguage(selectedCode);
      _showProfileFeedback(context.l10n.profileLanguageSaved);
    } else if (_profileController.errorMessage != null) {
      _showProfileFeedback(_resolveProfileMessage(_profileController.errorMessage!));
    }
  }

  String _resolveProfileMessage(String message) {
    switch (message) {
      case HomeUProfileController.errorRefreshProfile:
        return context.l10n.profileErrorRefresh;
      case HomeUProfileController.errorUpdateProfile:
        return context.l10n.profileErrorUpdate;
      case HomeUProfileController.errorUploadAvatar:
        return context.l10n.profileErrorUpload;
      case HomeUProfileController.errorSaveLanguage:
        return context.l10n.profileErrorLanguageSave;
      default:
        return context.l10n.profileErrorUpdate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(widget.role)) {
      return HomeURoleBlockedScreen(requiredRole: widget.role);
    }
    return AnimatedBuilder(
      animation: _profileController,
      builder: (context, _) {
        final t = context.l10n;
        final profile = _profileController.profile;
        final roleLabel = profile.role == HomeURole.owner
            ? t.profileRoleOwner
            : t.profileRoleTenant;
        final selectedLanguageLabel = _languageLabel(
          context,
          _profileController.selectedLanguageCode,
        );
        final selectedThemeLabel = _themeLabel(
          context,
          HomeUThemeController.instance.themeMode,
        );
        final hasNetworkAvatar =
            profile.profileImageUrl?.trim().isNotEmpty ?? false;
        final avatarUrl = hasNetworkAvatar
            ? _withAvatarCacheBust(profile.profileImageUrl!.trim())
            : null;
        final ImageProvider<Object>? avatarImage = _localAvatarPath != null
            ? FileImage(File(_localAvatarPath!))
            : (hasNetworkAvatar
                  ? NetworkImage(avatarUrl!)
                  : null);
        return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: AppBar(
            title: Text(t.profileTitle),
            backgroundColor: context.colors.surface,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = (width * 0.06).clamp(16.0, 24.0);
                final sectionGap = (width * 0.04).clamp(12.0, 18.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_profileController.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(minHeight: 2.5),
                        ),
                      _ProfileHeaderCard(
                        profile: profile,
                        roleLabel: roleLabel,
                        isSaving: _profileController.isSaving,
                        avatarImage: avatarImage,
                        onAvatarEdit: _profileController.isSaving
                            ? null
                            : () {
                                _editAvatar();
                              },
                      ),
                      SizedBox(height: sectionGap),
                      _ProfileDetailsCard(
                        name: profile.fullName,
                        email: profile.email,
                        phone: profile.phoneNumber,
                        roleLabel: roleLabel,
                      ),
                      if (_profileController.errorMessage != null) ...[
                        SizedBox(height: sectionGap),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD2D2)),
                          ),
                          child: Text(
                            _resolveProfileMessage(_profileController.errorMessage!),
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontSize: 12.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: sectionGap),
                      Container(
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.homeuAccent.withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (widget.role == HomeURole.tenant) ...[
                              _ProfileActionTile(
                                key: const Key('open_favorites_button'),
                                icon: Icons.favorite_border_rounded,
                                title: 'Favourite',
                                subtitle: 'View your saved properties',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const HomeUFavoritesScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: context.homeuSectionDivider,
                              ),
                            ],
                            _ProfileActionTile(
                              icon: Icons.palette_outlined,
                              title: t.profileThemeTitle,
                              subtitle: t.profileThemeSubtitle,
                              trailingText: selectedThemeLabel,
                              onTap: _openThemeSheet,
                            ),
                            Divider(
                              height: 1,
                              color: context.homeuSectionDivider,
                            ),
                            _ProfileActionTile(
                              icon: Icons.language_rounded,
                              title: t.profileLanguageTitle,
                              subtitle: t.profileLanguageSubtitle,
                              trailingText: selectedLanguageLabel,
                              onTap: _profileController.isSaving
                                  ? null
                                  : _openLanguageSheet,
                            ),
                            Divider(
                              height: 1,
                              color: context.homeuSectionDivider,
                            ),
                            _ProfileActionTile(
                              key: const Key('update_password_button'),
                              icon: Icons.lock_reset_rounded,
                              title: t.profileUpdatePasswordTitle,
                              subtitle: t.profileUpdatePasswordSubtitle,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const HomeUUpdatePasswordScreen(
                                          isRecoveryFlow: false,
                                        ),
                                  ),
                                );
                              },
                            ),
                            Divider(
                              height: 1,
                              color: context.homeuSectionDivider,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
                              child: SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: OutlinedButton(
                                  key: const Key('edit_profile_button'),
                                  onPressed: _profileController.isSaving
                                      ? null
                                      : () {
                                          _openEditProfileSheet(profile);
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.homeuAccent,
                                    side: BorderSide(
                                      color: context.homeuSoftBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: _profileController.isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(t.profileEditButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('logout_button'),
                          onPressed: () async {
                            try {
                              await HomeUAuthService.instance.signOut();
                            } catch (_) {
                              // Keep logout resilient even if remote sign-out fails.
                            }

                            HomeUSession.logout();

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (_) => const HomeULoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.homeuAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(t.profileLogoutButton),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

extension on _HomeUProfileScreenState {
  String _withAvatarCacheBust(String url) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$_avatarCacheBuster';
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.roleLabel,
    required this.isSaving,
    required this.avatarImage,
    required this.onAvatarEdit,
  });

  final HomeUProfileData profile;
  final String roleLabel;
  final bool isSaving;
  final ImageProvider<Object>? avatarImage;
  final VoidCallback? onAvatarEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onAvatarEdit,
                child: CircleAvatar(
                  key: const Key('profile_photo'),
                  radius: 42,
                  backgroundColor: const Color(0x1F1E3A8A),
                  backgroundImage: avatarImage,
                  child: avatarImage != null
                      ? null
                      : const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Color(0xFF9AB4FF),
                        ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: InkWell(
                    key: const Key('profile_photo_edit_button'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: onAvatarEdit,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            key: const Key('profile_name'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            key: const Key('profile_role'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1A10B981),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                color: context.isDarkMode
                    ? const Color(0xFF74E8BE)
                    : const Color(0xFF0F766E),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.roleLabel,
  });

  final String name;
  final String email;
  final String phone;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profileAccountDetails,
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ProfileDetailItem(
            icon: Icons.person_outline_rounded,
            label: context.l10n.profileFieldName,
            value: name,
          ),
          const SizedBox(height: 12),
          _ProfileDetailItem(
            icon: Icons.email_outlined,
            label: context.l10n.profileFieldEmail,
            value: email,
          ),
          const SizedBox(height: 12),
          _ProfileDetailItem(
            icon: Icons.phone_outlined,
            label: context.l10n.profileFieldPhone,
            value: phone,
          ),
          const SizedBox(height: 12),
          _ProfileDetailItem(
            icon: Icons.badge_outlined,
            label: context.l10n.profileFieldRole,
            value: roleLabel,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailItem extends StatelessWidget {
  const _ProfileDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: context.homeuAccent.withValues(alpha: 0.22),
          child: Icon(icon, size: 17, color: context.homeuAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.homeuSecondaryText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 14.2,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.homeuAccent.withValues(alpha: 0.2),
              child: Icon(icon, color: context.homeuAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.homeuSecondaryText,
                      fontSize: 12.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  color: context.homeuSecondaryText,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: context.homeuAccent),
          ],
        ),
      ),
    );
  }
}

class _EditProfileInput {
  const _EditProfileInput({required this.fullName, required this.phoneNumber});

  final String fullName;
  final String phoneNumber;
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final HomeUProfileData profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: context.homeuCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.profileEditSheetTitle,
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.profileEditSheetPhotoHint,
                  style: TextStyle(
                    color: context.homeuHelperText,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                _EditableTextField(
                  label: context.l10n.profileEditFieldFullName,
                  hintText: context.l10n.profileEditFieldFullNameHint,
                  controller: _fullNameController,
                ),
                const SizedBox(height: 12),
                _EditableTextField(
                  label: context.l10n.profileEditFieldEmailReadonly,
                  hintText: widget.profile.email,
                  enabled: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                _EditableTextField(
                  label: context.l10n.profileEditFieldPhone,
                  hintText: context.l10n.profileEditFieldPhoneHint,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _EditProfileInput(
                          fullName: _fullNameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.homeuAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(context.l10n.profileEditSaveChanges),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableTextField extends StatelessWidget {
  const _EditableTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.homeuSecondaryText,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: context.homeuRaisedCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.homeuAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

enum _AvatarAction { gallery, camera }
