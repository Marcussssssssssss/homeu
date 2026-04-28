import 'package:flutter/material.dart';
import 'package:homeu/app/auth/login/login_controller.dart';
import 'package:homeu/app/auth/login/login_models.dart';
import 'package:homeu/app/auth/login/login_repository.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/biometric_auth_service.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/home_tenant_shell_screen.dart';
import 'package:homeu/pages/home/home_owner_shell_screen.dart';
import 'package:homeu/pages/home/home_admin_shell_screen.dart';
import 'package:homeu/pages/auth/register_screen.dart';

import 'forgot_password_screen.dart';

class HomeULoginScreen extends StatefulWidget {
  const HomeULoginScreen({super.key, this.loginController});

  final LoginController? loginController;

  @override
  State<HomeULoginScreen> createState() => _HomeULoginScreenState();
}

class _HomeULoginScreenState extends State<HomeULoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  HomeURememberedUser? _rememberedUser;
  bool _isBiometricAvailable = false;

  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = widget.loginController ?? LoginController();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final authService = HomeUAuthService.instance;
    final biometricService = BiometricAuthService.instance;

    final user = await biometricService.getRememberedUser();
    final hasSession = authService.hasActiveSession;
    final currentUserId = authService.currentUserId;

    // Show biometric quick login only if:
    // 1. Biometric is enabled and a user is remembered locally
    // 2. Hardware supports it
    // 3. A valid Supabase session exists to unlock
    // 4. The current session user matches the remembered user
    if (user != null && hasSession && currentUserId == user.userId) {
      final isSupported = await biometricService.isDeviceSupported();
      if (isSupported && mounted) {
        setState(() {
          _rememberedUser = user;
          _isBiometricAvailable = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome(HomeURole role) {
    debugPrint('HomeULoginScreen: [DEBUG] Navigating for role: $role');
    HomeUSession.register(role);
    
    Widget destination;
    if (role == HomeURole.admin) {
      debugPrint('HomeULoginScreen: [DEBUG] Destination: Admin Dashboard');
      destination = const HomeUAdminShellScreen();
    } else if (role == HomeURole.owner) {
      debugPrint('HomeULoginScreen: [DEBUG] Destination: Owner Shell');
      destination = const HomeUOwnerShellScreen();
    } else {
      debugPrint('HomeULoginScreen: [DEBUG] Destination: Tenant Shell');
      destination = const HomeUTenantShellScreen();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Future<void> _handleBiometricLogin() async {
    if (_isLoading) return;

    final success = await BiometricAuthService.instance.authenticateWithBiometrics(
      localizedReason: 'Authenticate to access HomeU',
    );

    if (success && mounted) {
      if (HomeUAuthService.instance.hasActiveSession) {
        final role = await HomeUAuthService.instance.fetchCurrentUserRole();
        debugPrint('HomeULoginScreen: [DEBUG] Biometric fetch role: $role');
        if (role != null) {
          // Unlock the app locally
          await BiometricAuthService.instance.setAppLocked(false);
          _navigateToHome(role);
          return;
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login with email and password.')),
      );
      setState(() {
        _isBiometricAvailable = false;
        _rememberedUser = null;
      });
    } else if (!success && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _loginController.submit(
      LoginPayload(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (!result.isSuccess || result.role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_resolveLoginMessage(result.message))),
      );
      return;
    }

    debugPrint('HomeULoginScreen: [DEBUG] Login successful. ID: ${HomeUAuthService.instance.currentUserId}, Role: ${result.role}');

    // Success normal login: ensure app is not locked locally
    await BiometricAuthService.instance.setAppLocked(false);
    _navigateToHome(result.role!);
  }

  String _resolveLoginMessage(String message) {
    switch (message) {
      case LoginRepository.successLogin:
        return context.l10n.loginSuccess;
      case LoginRepository.errorBackendNotInitialized:
        return context.l10n.loginErrorBackendNotInitialized;
      case LoginRepository.errorLoginIncomplete:
        return context.l10n.loginErrorIncomplete;
      case LoginRepository.errorProfileRoleMissing:
        return context.l10n.loginErrorProfileRoleMissing;
      case LoginRepository.errorNetwork:
        return context.l10n.loginErrorNetwork;
      case LoginRepository.errorProfileRead:
        return context.l10n.loginErrorProfileRead;
      case LoginRepository.errorUnexpected:
        return context.l10n.loginErrorUnexpected;
      case LoginRepository.errorInvalidCredentials:
        return context.l10n.loginErrorInvalidCredentials;
      case LoginRepository.errorGeneric:
        return context.l10n.loginErrorGeneric;
      default:
        return context.l10n.loginErrorGeneric;
    }
  }

  String? _validateRequired(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.formFieldRequired(fieldName);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.08).clamp(20.0, 28.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                24,
              ),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.homeuCard,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: context.homeuAccent.withValues(
                                  alpha: 0.16,
                                ),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('HomeU.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.loginTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_isBiometricAvailable && _rememberedUser != null) ...[
                        _QuickLoginCard(
                          name: _rememberedUser!.displayName,
                          onPressed: _handleBiometricLogin,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: context.homeuSoftBorder)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: context.homeuMutedText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: context.homeuSoftBorder)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      _LabeledInput(
                        label: t.profileFieldEmail,
                        hintText: t.authEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        fieldKey: const Key('login_email_field'),
                        controller: _emailController,
                        enabled: !_isLoading,
                        validator: (value) => _validateRequired(
                          value,
                          fieldName: t.profileFieldEmail,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LabeledInput(
                        label: t.authPassword,
                        hintText: t.loginPasswordHint,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        fieldKey: const Key('login_password_field'),
                        visibilityToggleKey: const Key(
                          'login_password_visibility_toggle',
                        ),
                        controller: _passwordController,
                        enabled: !_isLoading,
                        validator: (value) =>
                            _validateRequired(value, fieldName: t.authPassword),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const HomeUForgotPasswordPage(),
                                    ),
                                  );
                                },
                          child: Text(t.loginForgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(t.authLogin),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.loginNewHere,
                            style: TextStyle(
                              color: context.homeuMutedText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const HomeURegisterScreen(),
                                      ),
                                    );
                                  },
                            child: Text(t.authRegister),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickLoginCard extends StatelessWidget {
  const _QuickLoginCard({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.homeuSoftBorder),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Continue as $name',
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Use Biometrics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.homeuAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledInput extends StatefulWidget {
  const _LabeledInput({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.enabled,
    this.fieldKey,
    this.visibilityToggleKey,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool enabled;
  final Key? fieldKey;
  final Key? visibilityToggleKey;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<_LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<_LabeledInput> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: context.homeuPrimaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _isObscured,
          validator: widget.validator,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: widget.obscureText
                ? IconButton(
                    key: widget.visibilityToggleKey,
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: _isObscured
                        ? context.l10n.authShowPassword
                        : context.l10n.authHidePassword,
                  )
                : null,
            filled: true,
            fillColor: context.homeuCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.homeuSoftBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.homeuAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
