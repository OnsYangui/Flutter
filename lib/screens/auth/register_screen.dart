import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_indicator.dart';
import 'login_screen.dart';

const _primary = Color(0xFF00BCD4);
const _bgLight = Color(0xFFF0FAFB);
const _textDark = Color(0xFF1A1A2E);
const _textMid = Color(0xFF9E9BB4);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isLoading) {
            return const LoadingIndicator(message: 'Création du compte...');
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Créer un compte', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Rejoignez votre assistant médical', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85))),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text('Informations personnelles',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textMid, letterSpacing: 0.5)),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(child: _OzField(controller: _firstNameController, label: 'Prénom', icon: Icons.person_outline_rounded, validator: Validators.validateName)),
                            const SizedBox(width: 12),
                            Expanded(child: _OzField(controller: _lastNameController, label: 'Nom', icon: Icons.person_outline_rounded, validator: Validators.validateName)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _OzField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.validateEmail),
                        const SizedBox(height: 20),

                        const Text('Sécurité',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textMid, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        _OzField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: _textMid, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _OzField(
                          controller: _confirmPasswordController,
                          label: 'Confirmer le mot de passe',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          validator: (v) => v != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: _textMid, size: 20),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authService.register(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                );
                                if (success && mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authService.errorMessage ?? 'Erreur'), backgroundColor: const Color(0xFFFF5A7D)),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Créer mon compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Déjà un compte ? ', style: TextStyle(color: _textMid)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Se connecter', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OzField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _OzField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: _textDark, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMid, fontSize: 14),
        prefixIcon: Icon(icon, color: _textMid, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE8E6F5))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE8E6F5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF5A7D), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF5A7D), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}