import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart'; // Ensure this file exists and exports SignupScreen class

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await context.read<AuthService>().login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (error != null) {
      setState(() => _error = error);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/waste_watch_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A3A1A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Sign in to continue reporting waste',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 40),

              // Error banner
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFC62828),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              _FieldLabel('Email address'),
              const SizedBox(height: 8),
              _InputField(
                controller: _emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Password field
              _FieldLabel('Password'),
              const SizedBox(height: 8),
              _InputField(
                controller: _passCtrl,
                hint: '••••••••',
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 32),

              // Login button
              CustomButton(label: 'Sign In', loading: _loading, onTap: _login),

              const SizedBox(height: 24),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A3A1A),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
