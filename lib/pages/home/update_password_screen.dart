import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/update_password/update_password_controller.dart';
import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/pages/auth/login_screen.dart';

class HomeUUpdatePasswordScreen extends StatefulWidget {
  const HomeUUpdatePasswordScreen({
    super.key,
    this.controller,
    this.isRecoveryFlow = false,
  });

  final UpdatePasswordController? controller;
  final bool isRecoveryFlow;

  @override
  State<HomeUUpdatePasswordScreen> createState() => _HomeUUpdatePasswordScreenState();
}

class _HomeUUpdatePasswordScreenState extends State<HomeUUpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _feedbackMessage;
  bool _isErrorMessage = false;

  late final UpdatePasswordController _controller;

  bool get _shouldShowCurrentPasswordField => !widget.isRecoveryFlow;

  String get _helperText => widget.isRecoveryFlow
      ? 'Set a new password for your account to complete password recovery.'
      : 'Change your password to keep your account secure.';

  String get _submitButtonText => widget.isRecoveryFlow ? 'Set New Password' : 'Update Password';

  String get _cancelButtonText => widget.isRecoveryFlow ? 'Back to Login' : 'Cancel';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdatePasswordController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (_isLoading) {
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
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
        isRecoveryFlow: widget.isRecoveryFlow,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isErrorMessage = !result.isSuccess;
      _feedbackMessage = result.message;
    });

    if (!result.isSuccess) {
      return;
    }

    if (widget.isRecoveryFlow) {
      try {
        await HomeUAuthService.instance.signOut();
      } catch (_) {
        // Keep redirect resilient even if sign-out fails.
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeULoginScreen()),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'New password is required';
    }
    if (value.trim().length < 6) {
      return 'New password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm new password is required';
    }
    if (value.trim() != _newPasswordController.text.trim()) {
      return 'New password and confirmation do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Update Password'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.06).clamp(16.0, 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 20),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const Text(
                      'Update Password',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _helperText,
                      style: const TextStyle(
                        color: Color(0xFF50617F),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          if (_shouldShowCurrentPasswordField) ...[
                            _PasswordInputField(
                              key: const Key('current_password_field'),
                              label: 'Current Password (optional)',
                              hintText: 'Enter current password',
                              controller: _currentPasswordController,
                              enabled: !_isLoading,
                              obscureText: _obscureCurrentPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureCurrentPassword = !_obscureCurrentPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          _PasswordInputField(
                            key: const Key('new_password_field'),
                            label: 'New Password',
                            hintText: 'Enter new password',
                            controller: _newPasswordController,
                            enabled: !_isLoading,
                            validator: _validateNewPassword,
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
                            label: 'Confirm New Password',
                            hintText: 'Re-enter new password',
                            controller: _confirmPasswordController,
                            enabled: !_isLoading,
                            validator: _validateConfirmPassword,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _feedbackMessage == null
                            ? Colors.transparent
                            : (_isErrorMessage
                                  ? const Color(0xFFFFF2F2)
                                  : const Color(0xFFF0FBF5)),
                        borderRadius: BorderRadius.circular(12),
                        border: _feedbackMessage == null
                            ? null
                            : Border.all(
                                  color: _isErrorMessage
                                      ? const Color(0xFFFFD2D2)
                                      : const Color(0xFFAEE7C4),
                                ),
                      ),
                      child: _feedbackMessage == null
                          ? const SizedBox.shrink()
                          : Row(
                              key: const Key('password_feedback_message'),
                              children: [
                                Icon(
                                  _isErrorMessage ? Icons.error_outline_rounded : Icons.check_circle_outline,
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
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('update_password_submit_button'),
                        onPressed: _isLoading ? null : _handleUpdatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(_submitButtonText),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        key: const Key('cancel_update_password_button'),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (widget.isRecoveryFlow) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const HomeULoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  return;
                                }
                                Navigator.of(context).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          side: const BorderSide(color: Color(0x331E3A8A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: Text(_cancelButtonText),
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
    this.enabled = true,
    this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool enabled;
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
          style: const TextStyle(
            color: Color(0xFF1F314F),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              tooltip: obscureText ? 'Show password' : 'Hide password',
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

