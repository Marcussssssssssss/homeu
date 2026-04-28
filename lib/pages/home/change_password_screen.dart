import 'package:flutter/material.dart';
import 'package:homeu/app/auth/update_password/update_password_controller.dart';
import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/app/auth/update_password/update_password_repository.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

class HomeUChangePasswordScreen extends StatefulWidget {
  const HomeUChangePasswordScreen({super.key, this.controller});

  final UpdatePasswordController? controller;

  @override
  State<HomeUChangePasswordScreen> createState() =>
      _HomeUChangePasswordScreenState();
}

class _HomeUChangePasswordScreenState extends State<HomeUChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _feedbackMessage;
  bool _isErrorMessage = false;

  late final UpdatePasswordController _controller;

  bool get _isFormReady {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      return false;
    }
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      return false;
    }
    if (newPassword.length < 6) {
      return false;
    }
    return newPassword == confirmPassword;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdatePasswordController();
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      if (_feedbackMessage != null) {
        _feedbackMessage = null;
      }
    });
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onFieldChanged);
    _newPasswordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_isLoading || !_isFormReady) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final result = await _controller.submit(
      UpdatePasswordPayload(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
        isRecoveryFlow: false,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isErrorMessage = !result.isSuccess;
      _feedbackMessage = _resolveSubmissionMessage(result);
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.updatePasswordSuccessMessage),
          backgroundColor: const Color(0xFF1F9254),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _resolveSubmissionMessage(UpdatePasswordSubmissionResult result) {
    if (result.isSuccess) {
      return context.l10n.updatePasswordSuccessMessage;
    }
    return _resolveFailureMessage(result.message);
  }

  String _resolveFailureMessage(String message) {
    switch (message) {
      case UpdatePasswordRepository.validationCurrentPasswordRequired:
        return context.l10n.updatePasswordValidationCurrentRequired;
      case UpdatePasswordRepository.validationNewPasswordRequired:
        return context.l10n.updatePasswordValidationNewRequired;
      case UpdatePasswordRepository.validationConfirmPasswordRequired:
        return context.l10n.updatePasswordValidationConfirmRequired;
      case UpdatePasswordRepository.validationMismatch:
        return context.l10n.updatePasswordValidationMismatch;
      case UpdatePasswordRepository.validationMinLength:
        return context.l10n.updatePasswordValidationMinLength;
      case UpdatePasswordRepository.errorCurrentPasswordIncorrect:
        return context.l10n.updatePasswordErrorCurrentPasswordIncorrect;
      case UpdatePasswordRepository.errorBackendNotInitialized:
        return context.l10n.updatePasswordErrorBackendNotInitialized;
      case UpdatePasswordRepository.errorVerifyCurrentPasswordUnavailable:
        return context.l10n.updatePasswordErrorVerifyCurrentPasswordUnavailable;
      case UpdatePasswordRepository.errorSessionExpired:
        return context.l10n.updatePasswordErrorSessionExpired;
      case UpdatePasswordRepository.errorNewPasswordMustDiffer:
        return context.l10n.updatePasswordErrorNewPasswordMustDiffer;
      case UpdatePasswordRepository.errorWeakPassword:
        return context.l10n.updatePasswordErrorWeakPassword;
      case UpdatePasswordRepository.errorNetwork:
        return context.l10n.updatePasswordErrorNetwork;
      default:
        return context.l10n.updatePasswordErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isFormReady && !_isLoading;
    final t = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(t.profileUpdatePasswordTitle),
        backgroundColor: context.colors.surface,
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
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.profileUpdatePasswordTitle,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.profileUpdatePasswordSubtitle,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
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
                          child: Image.asset('HomeU.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? const Color(0xFF11211D)
                              : const Color(0xFFF0FBF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.homeuSuccess.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security_rounded,
                              color: Color(0xFF1F9254),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.updatePasswordStrongPasswordTip,
                                style: const TextStyle(
                                  color: Color(0xFF1F9254),
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.homeuAccent.withValues(
                                alpha: 0.16,
                              ),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _PasswordInputField(
                              key: const Key('current_password_field'),
                              label: t.updatePasswordCurrentPasswordLabel,
                              hintText: t.updatePasswordCurrentPasswordHint,
                              controller: _currentPasswordController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t
                                      .updatePasswordValidationCurrentRequired;
                                }
                                return null;
                              },
                              obscureText: _obscureCurrentPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            _PasswordInputField(
                              key: const Key('new_password_field'),
                              label: t.updatePasswordNewPasswordLabel,
                              hintText: t.updatePasswordNewPasswordHint,
                              controller: _newPasswordController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t.updatePasswordValidationNewRequired;
                                }
                                if (value.trim().length < 6) {
                                  return t.updatePasswordValidationMinLength;
                                }
                                return null;
                              },
                              obscureText: _obscureNewPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            _PasswordInputField(
                              key: const Key('confirm_new_password_field'),
                              label: t.updatePasswordConfirmPasswordLabel,
                              hintText: t.updatePasswordConfirmPasswordHint,
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t
                                      .updatePasswordValidationConfirmRequired;
                                }
                                if (value.trim() !=
                                    _newPasswordController.text.trim()) {
                                  return t.updatePasswordValidationMismatch;
                                }
                                return null;
                              },
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_feedbackMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _isErrorMessage
                                ? const Color(0xFFFFF2F2)
                                : (context.isDarkMode
                                      ? const Color(0xFF11211D)
                                      : const Color(0xFFF0FBF5)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isErrorMessage
                                  ? const Color(0xFFFFD2D2)
                                  : context.homeuSuccess.withValues(
                                      alpha: 0.45,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isErrorMessage
                                    ? Icons.error_outline_rounded
                                    : Icons.check_circle_outline,
                                color: _isErrorMessage
                                    ? const Color(0xFFB42318)
                                    : const Color(0xFF1F9254),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _feedbackMessage!,
                                  style: TextStyle(
                                    color: _isErrorMessage
                                        ? const Color(0xFFB42318)
                                        : const Color(0xFF1F9254),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSubmit ? _handleChangePassword : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.homeuAccent,
                            disabledBackgroundColor: context.homeuAccent
                                .withValues(alpha: 0.5),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
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
                              : Text(t.profileUpdatePasswordTitle),
                        ),
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

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.homeuPrimaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: obscureText
                  ? context.l10n.authShowPassword
                  : context.l10n.authHidePassword,
            ),
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
