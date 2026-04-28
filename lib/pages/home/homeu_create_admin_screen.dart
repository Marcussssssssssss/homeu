import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

class HomeUCreateAdminScreen extends StatefulWidget {
  const HomeUCreateAdminScreen({super.key});

  @override
  State<HomeUCreateAdminScreen> createState() => _HomeUCreateAdminScreenState();
}

class _HomeUCreateAdminScreenState extends State<HomeUCreateAdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await AppSupabase.client.functions.invoke(
        'create-admin-user',
        body: {
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.status < 200 || response.status >= 300) {
        throw Exception(_extractErrorMessage(response.data));
      }

      if (response.data is Map) {
        final dataMap = Map<String, dynamic>.from(response.data as Map);
        if (dataMap['error'] != null) {
          throw Exception(dataMap['error'].toString());
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _extractErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _extractErrorMessage(Object? error) {
    if (error == null) {
      return 'Failed to create admin account. Please try again.';
    }

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    if (error is Map) {
      final message = error['message'] ?? error['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
      return 'Failed to create admin account. Please try again.';
    }

    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }

    return text.trim().isEmpty
        ? 'Failed to create admin account. Please try again.'
        : text.trim();
  }

  String? _validateRequired(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.admin)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.admin);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Create Admin Account'),
        backgroundColor: context.colors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => _validateRequired(value, 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final requiredError = _validateRequired(value, 'Email');
                    if (requiredError != null) {
                      return requiredError;
                    }
                    if (!_emailRegex.hasMatch(value!.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => _validateRequired(value, 'Phone Number'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    final requiredError = _validateRequired(value, 'Password');
                    if (requiredError != null) {
                      return requiredError;
                    }
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    final requiredError = _validateRequired(value, 'Confirm Password');
                    if (requiredError != null) {
                      return requiredError;
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.homeuAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Admin'),
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


