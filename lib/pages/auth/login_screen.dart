import 'package:flutter/material.dart';
import 'package:homeu/app/auth/login/login_controller.dart';
import 'package:homeu/app/auth/login/login_models.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/auth/register_screen.dart';
import 'package:homeu/pages/home/owner_dashboard_screen.dart';

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

  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = widget.loginController ?? LoginController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    HomeUSession.register(result.role!);

    final Widget destination = result.role == HomeURole.owner
        ? const HomeUOwnerDashboardScreen()
        : const HomeUHomePage();

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
                      'Welcome Back',
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
                      'Login to continue your HomeU journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF50617F),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _LabeledInput(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      fieldKey: const Key('login_email_field'),
                      controller: _emailController,
                      enabled: !_isLoading,
                      validator: (value) => _validateRequired(value, fieldName: 'Email'),
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Password',
                      hintText: 'Enter your password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      fieldKey: const Key('login_password_field'),
                      visibilityToggleKey: const Key('login_password_visibility_toggle'),
                      controller: _passwordController,
                      enabled: !_isLoading,
                      validator: (value) => _validateRequired(value, fieldName: 'Password'),
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
                              builder: (_) => const HomeUForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometric authentication coming soon.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text('Use Fingerprint'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          side: const BorderSide(color: Color(0x331E3A8A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New here?',
                          style: TextStyle(
                            color: Color(0xFF50617F),
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
                                builder: (_) => const HomeURegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Register'),
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


