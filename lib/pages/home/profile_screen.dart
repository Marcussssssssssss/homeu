import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/auth/login_screen.dart';
import 'package:homeu/pages/home/update_password_screen.dart';

class HomeUProfileScreen extends StatefulWidget {
  const HomeUProfileScreen({
    super.key,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    this.profileController,
  });

  final HomeURole role;
  final String name;
  final String email;
  final String phone;

  final HomeUProfileController? profileController;

  @override
  State<HomeUProfileScreen> createState() => _HomeUProfileScreenState();
}

class _HomeUProfileScreenState extends State<HomeUProfileScreen> {
  late final HomeUProfileController _profileController;

  @override
  void initState() {
    super.initState();
    final userId = HomeUAuthService.instance.currentUserId ?? 'preview-user';
    final initialProfile = HomeUProfileData(
      userId: userId,
      fullName: widget.name,
      email: widget.email,
      phoneNumber: widget.phone,
      role: widget.role,
    );

    _profileController =
        widget.profileController ?? HomeUProfileController(initialProfile: initialProfile);
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
    final fullNameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final imageUrlController = TextEditingController(text: profile.profileImageUrl ?? '');

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(bottomContext).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xFF1F314F),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _EditableTextField(
                        label: 'Full Name',
                        hintText: 'Enter full name',
                        controller: fullNameController,
                      ),
                      const SizedBox(height: 12),
                      _EditableTextField(
                        label: 'Phone Number',
                        hintText: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                      ),
                      const SizedBox(height: 12),
                      _EditableTextField(
                        label: 'Profile Image URL (placeholder)',
                        hintText: 'https://example.com/profile.jpg',
                        keyboardType: TextInputType.url,
                        controller: imageUrlController,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _profileController.isSaving
                              ? null
                              : () async {
                                  final name = fullNameController.text.trim();
                                  final phone = phoneController.text.trim();
                                  final imageUrl = imageUrlController.text.trim();
                                  if (name.isEmpty || phone.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Name and phone number are required.'),
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await _profileController.updateProfile(
                                    fullName: name,
                                    phoneNumber: phone,
                                    profileImageUrl: imageUrl.isEmpty ? null : imageUrl,
                                  );

                                  if (!context.mounted) {
                                    return;
                                  }

                                  Navigator.of(context).pop(success);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _profileController.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    fullNameController.dispose();
    phoneController.dispose();
    imageUrlController.dispose();

    if (!mounted) {
      return;
    }

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } else if (_profileController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileController.errorMessage!)),
      );
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
        final profile = _profileController.profile;
        final roleLabel = profile.role == HomeURole.owner ? 'Owner' : 'Tenant';
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFFF6F8FC),
            elevation: 0,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = (width * 0.06).clamp(16.0, 24.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_profileController.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: LinearProgressIndicator(minHeight: 2.5),
                          ),
                    Center(
                      child: CircleAvatar(
                        key: const Key('profile_photo'),
                        radius: 46,
                        backgroundColor: const Color(0x1F1E3A8A),
                        backgroundImage: (profile.profileImageUrl?.trim().isNotEmpty ?? false)
                            ? NetworkImage(profile.profileImageUrl!)
                            : null,
                        child: (profile.profileImageUrl?.trim().isNotEmpty ?? false)
                            ? null
                            : const Icon(
                                Icons.person_rounded,
                                size: 52,
                                color: Color(0xFF1E3A8A),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.fullName,
                      key: const Key('profile_name'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1F314F),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLabel,
                      key: const Key('profile_role'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x141E3A8A),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ProfileInfoRow(label: 'Name', value: profile.fullName),
                          const SizedBox(height: 10),
                          _ProfileInfoRow(label: 'Email', value: profile.email),
                          const SizedBox(height: 10),
                          _ProfileInfoRow(label: 'Phone Number', value: profile.phoneNumber),
                          const SizedBox(height: 10),
                          _ProfileInfoRow(label: 'Role', value: roleLabel),
                        ],
                      ),
                    ),
                    if (_profileController.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD2D2)),
                        ),
                        child: Text(
                          _profileController.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB42318),
                            fontSize: 12.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x141E3A8A),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        key: const Key('update_password_button'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeUUpdatePasswordScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0x1A22C55E),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Update Password',
                                      style: TextStyle(
                                        color: Color(0xFF1F314F),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Change your password to keep your account secure.',
                                      style: TextStyle(
                                        color: Color(0xFF667896),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded, color: Color(0xFF1E3A8A)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        key: const Key('edit_profile_button'),
                        onPressed: () {
                          _openEditProfileSheet(profile);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          side: const BorderSide(color: Color(0x331E3A8A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            MaterialPageRoute<void>(builder: (_) => const HomeULoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                      ],
                    ),
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

class _EditableTextField extends StatelessWidget {
  const _EditableTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1F314F),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 122,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667896),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

