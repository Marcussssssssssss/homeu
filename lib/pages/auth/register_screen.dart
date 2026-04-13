import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/home/owner_dashboard_screen.dart';

class HomeURegisterScreen extends StatefulWidget {
  const HomeURegisterScreen({super.key});

  @override
  State<HomeURegisterScreen> createState() => _HomeURegisterScreenState();
}

class _HomeURegisterScreenState extends State<HomeURegisterScreen> {
  HomeURole _selectedRole = HomeURole.tenant;

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
                    const _LabeledInput(
                      label: 'Name',
                      hintText: 'Your full name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _LabeledInput(
                      label: 'Phone Number',
                      hintText: '+60 12 345 6789',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 14),
                    const _LabeledInput(
                      label: 'Password',
                      hintText: 'Create a password',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
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
                              onSelected: (_) {
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
                              onSelected: (_) {
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
                        onPressed: () {
                          HomeUSession.register(_selectedRole);

                          final Widget destination = _selectedRole == HomeURole.owner
                              ? const HomeUOwnerDashboardScreen()
                              : const HomeUHomePage();

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => destination,
                            ),
                          );
                        },
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
                        child: const Text('Register'),
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
            );
          },
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

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
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
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

