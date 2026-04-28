import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUCreateAdminScreen extends StatefulWidget {
  const HomeUCreateAdminScreen({super.key});

  @override
  State<HomeUCreateAdminScreen> createState() => _HomeUCreateAdminScreenState();
}

class _HomeUCreateAdminScreenState extends State<HomeUCreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.formFieldRequired(fieldName);
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _validateRequired(
      value,
      fieldName: context.l10n.profileFieldEmail,
    );
    if (required != null) {
      return required;
    }

    final email = value!.trim();
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isEmail) {
      return context.l10n.formEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final required = _validateRequired(
      value,
      fieldName: context.l10n.authPassword,
    );
    if (required != null) {
      return required;
    }

    if (value!.length < 6) {
      return context.l10n.formPasswordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final required = _validateRequired(
      value,
      fieldName: context.l10n.registerConfirmPassword,
    );
    if (required != null) {
      return required;
    }

    if (value != _passwordController.text) {
      return context.l10n.formPasswordMismatch;
    }
    return null;
  }

  Future<void> _handleCreateAdmin() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AppSupabase.client.functions.invoke(
        'create-admin-user',
        body: {
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == true) {
          Navigator.of(context).pop(true);
          return;
        }

        final errorMessage = data['error'] ?? data['message'];
        if (errorMessage is String && errorMessage.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create admin account.')),
      );
    } on FunctionException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

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
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset('HomeU.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Admin Account',
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
                        'Create a new administrator with full access.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _LabeledInput(
                        label: t.profileFieldName,
                        hintText: t.registerNameHint,
                        prefixIcon: Icons.person_outline_rounded,
                        fieldKey: const Key('create_admin_name_field'),
                        controller: _nameController,
                        validator: (value) => _validateRequired(
                          value,
                          fieldName: t.profileFieldName,
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 14),
                      _LabeledInput(
                        label: t.profileFieldEmail,
                        hintText: t.authEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        fieldKey: const Key('create_admin_email_field'),
                        controller: _emailController,
                        validator: _validateEmail,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 14),
                      _LabeledInput(
                        label: t.profileFieldPhone,
                        hintText: '+60 12 345 6789',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        fieldKey: const Key('create_admin_phone_field'),
                        controller: _phoneController,
                        validator: (value) => _validateRequired(
                          value,
                          fieldName: t.profileFieldPhone,
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 14),
                      _LabeledInput(
                        label: t.authPassword,
                        hintText: t.registerPasswordHint,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        fieldKey: const Key('create_admin_password_field'),
                        visibilityToggleKey: const Key(
                          'create_admin_password_visibility_toggle',
                        ),
                        controller: _passwordController,
                        validator: _validatePassword,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 14),
                      _LabeledInput(
                        label: t.registerConfirmPassword,
                        hintText: t.registerConfirmPasswordHint,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        fieldKey: const Key('create_admin_confirm_password_field'),
                        visibilityToggleKey: const Key(
                          'create_admin_confirm_password_visibility_toggle',
                        ),
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCreateAdmin,
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
                              : const Text('Create Admin'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Back to Admin Management',
                            style: TextStyle(
                              color: context.homeuMutedText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Go back'),
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
          enabled: widget.enabled,
          validator: widget.validator,
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



