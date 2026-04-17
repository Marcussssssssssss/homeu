import 'package:flutter/material.dart';
import 'package:homeu/app/auth/register/register_controller.dart';
import 'package:homeu/app/auth/register/register_models.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/home/owner_dashboard_screen.dart';

class HomeURegisterScreen extends StatefulWidget {
  const HomeURegisterScreen({super.key, this.registerController});

  final RegisterController? registerController;

  @override
  State<HomeURegisterScreen> createState() => _HomeURegisterScreenState();
}

class _HomeURegisterScreenState extends State<HomeURegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  HomeURole _selectedRole = HomeURole.tenant;
  bool _isLoading = false;

  late final RegisterController _registerController;

  @override
  void initState() {
    super.initState();
    _registerController = widget.registerController ?? RegisterController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = RegisterPayload(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() {
      _isLoading = true;
    });

    final result = await _registerController.submit(payload);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result.status == RegisterSubmissionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    if (result.requiresEmailVerification) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Verify Your Email'),
            content: Text(result.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Back to Login'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    HomeUSession.register(result.resolvedRole);
    final Widget destination = result.resolvedRole == HomeURole.owner
        ? const HomeUOwnerDashboardScreen()
        : const HomeUHomePage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => destination,
      ),
    );
  }

  String? _validateRequired(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _validateRequired(value, fieldName: 'Email');
    if (required != null) {
      return required;
    }

    final email = value!.trim();
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final required = _validateRequired(value, fieldName: 'Password');
    if (required != null) {
      return required;
    }

    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final required = _validateRequired(value, fieldName: 'Confirm Password');
    if (required != null) {
      return required;
    }

    if (value != _passwordController.text) {
      return 'Password and confirm password do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x141E3A8A),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset('HomeU.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join HomeU and start your rental journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF50617F),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _LabeledInput(
                      label: 'Name',
                      hintText: 'Your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      fieldKey: const Key('register_name_field'),
                      controller: _nameController,
                      validator: (value) => _validateRequired(value, fieldName: 'Name'),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      fieldKey: const Key('register_email_field'),
                      controller: _emailController,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Phone Number',
                      hintText: '+60 12 345 6789',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      fieldKey: const Key('register_phone_field'),
                      controller: _phoneController,
                      validator: (value) => _validateRequired(value, fieldName: 'Phone Number'),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Password',
                      hintText: 'Create a password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      fieldKey: Key('register_password_field'),
                      visibilityToggleKey: const Key('register_password_visibility_toggle'),
                      controller: _passwordController,
                      validator: _validatePassword,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      fieldKey: Key('register_confirm_password_field'),
                      visibilityToggleKey: const Key('register_confirm_password_visibility_toggle'),
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Select Account Role',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x1F1E3A8A)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x101E3A8A),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              key: const Key('role_tenant_chip'),
                              label: const Text('Tenant'),
                              selected: _selectedRole == HomeURole.tenant,
                              onSelected: _isLoading
                                  ? null
                                  : (_) {
                                setState(() {
                                  _selectedRole = HomeURole.tenant;
                                });
                              },
                              selectedColor: const Color(0xFF1E3A8A),
                              labelStyle: TextStyle(
                                color: _selectedRole == HomeURole.tenant
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w700,
                              ),
                              side: const BorderSide(color: Color(0x331E3A8A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              key: const Key('role_owner_chip'),
                              label: const Text('Owner'),
                              selected: _selectedRole == HomeURole.owner,
                              onSelected: _isLoading
                                  ? null
                                  : (_) {
                                setState(() {
                                  _selectedRole = HomeURole.owner;
                                });
                              },
                              selectedColor: const Color(0xFF1E3A8A),
                              labelStyle: TextStyle(
                                color: _selectedRole == HomeURole.owner
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w700,
                              ),
                              side: const BorderSide(color: Color(0x331E3A8A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Your selected role controls accessible features and navigation. To switch roles later, log out and register again under the other role.',
                        style: TextStyle(
                          color: Color(0xFF40526E),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Color(0xFF50617F),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Back to Login'),
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
          style: const TextStyle(
            color: Color(0xFF1F314F),
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
                      _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    tooltip: _isObscured ? 'Show password' : 'Hide password',
                  )
                : null,
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

