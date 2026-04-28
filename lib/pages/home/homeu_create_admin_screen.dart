import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

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

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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

      if (response.status != 200 && response.status != 201) {
        final errorMsg = _extractErrorMessage(response.data);
        throw Exception(errorMsg);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin account created successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_extractErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractErrorMessage(Object? error) {
    if (error is Map && error.containsKey('error')) {
      return error['error'].toString();
    }
    if (error is Map && error.containsKey('message')) {
      return error['message'].toString();
    }
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    final t = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Create Admin Account'),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.08).clamp(20.0, 28.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Admin Details',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in the information below to create a new administrator account.',
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _LabeledInput(
                      label: t.profileFieldName,
                      hintText: t.registerNameHint,
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _nameController,
                      validator: (value) => _validateRequired(
                        value,
                        fieldName: t.profileFieldName,
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    _LabeledInput(
                      label: t.profileFieldEmail,
                      hintText: t.authEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      controller: _emailController,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    _LabeledInput(
                      label: t.profileFieldPhone,
                      hintText: '+60 12 345 6789',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      validator: (value) => _validateRequired(
                        value,
                        fieldName: t.profileFieldPhone,
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    _LabeledInput(
                      label: t.authPassword,
                      hintText: t.registerPasswordHint,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      validator: _validatePassword,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    _LabeledInput(
                      label: t.registerConfirmPassword,
                      hintText: t.registerConfirmPasswordHint,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.homeuAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                            : const Text('Create Admin Account'),
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
  }
}

class _LabeledInput extends StatefulWidget {
  const _LabeledInput({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.enabled,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool enabled;
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
