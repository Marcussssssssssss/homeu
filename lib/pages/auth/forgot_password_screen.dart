import 'package:flutter/material.dart';
import 'package:homeu/app/auth/forgot_password/forgot_password_controller.dart';
import 'package:homeu/app/auth/forgot_password/forgot_password_models.dart';
import 'package:homeu/core/config/app_env.dart';

class HomeUForgotPasswordPage extends StatefulWidget {
  const HomeUForgotPasswordPage({
    super.key,
    this.controller,
    this.redirectTo,
  });

  final ForgotPasswordController? controller;
  final String? redirectTo;

  @override
  State<HomeUForgotPasswordPage> createState() => _HomeUForgotPasswordPageState();
}

class _HomeUForgotPasswordPageState extends State<HomeUForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _showSuccess = false;
  bool _isLoading = false;
  String _successMessage = 'A password reset link has been sent to your email.';

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ForgotPasswordController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _sendResetLink() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final result = await _controller.submit(
      ForgotPasswordPayload(
        email: _emailController.text.trim(),
        redirectTo: widget.redirectTo ?? AppEnv.passwordResetRedirectUrl,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    setState(() {
      _successMessage = result.message;
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.08).clamp(20.0, 28.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 6),
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
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
                      'Forgot Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your registered email address and we will send you a password reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF50617F),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F9F6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x3310B981)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Please use your real email address because the password reset link will be sent to your inbox.',
                              style: TextStyle(
                                color: Color(0xFF2B4B42),
                                fontSize: 12.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!_showSuccess) ...[
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          color: Color(0xFF1F314F),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('forgot_password_email_field'),
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _sendResetLink(),
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
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
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('send_reset_link_button'),
                          onPressed: _isLoading ? null : _sendResetLink,
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
                              : const Text('Send Reset Link'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton.icon(
                          key: const Key('back_to_login_link'),
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to Login'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A8A),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        key: const Key('forgot_password_success_message'),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x221E3A8A)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x121E3A8A),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: CircleAvatar(
                                key: Key('forgot_password_success_icon'),
                                radius: 30,
                                backgroundColor: Color(0x1A10B981),
                                child: Icon(
                                  Icons.mark_email_read_rounded,
                                  size: 30,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Check Your Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _successMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4F627F),
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Didn\'t receive the email? Check your spam folder or try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF7082A0),
                                fontSize: 12.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                key: const Key('back_to_login_link'),
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Back to Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

