import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======
import 'package:google_fonts/google_fonts.dart';
>>>>>>> add-font

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final res = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login')),
      );
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    } else {
      final msg = res.message ?? 'Registrasi gagal';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final isId = settings.locale.languageCode == 'id';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: isId ? 'Ubah bahasa' : 'Change language',
                        icon: Icon(
                          Icons.g_translate,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        onPressed: () {
                          final next = isId
                              ? const Locale('en')
                              : const Locale('id');
                          context.read<SettingsProvider>().setLocale(next);
                        },
                      ),
                      IconButton(
                        tooltip: settings.themeMode == ThemeMode.light
                            ? 'Gelap'
                            : 'Terang',
                        icon: Icon(
                          settings.themeMode == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        onPressed: () =>
                            context.read<SettingsProvider>().toggleTheme(),
                      ),
                    ],
                  ),
                  Text(
                    'Jollaly',
<<<<<<< HEAD
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
=======
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: -0.5,
                          ),
>>>>>>> add-font
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
<<<<<<< HEAD
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.04),
=======
                              ? Colors.black.withAlpha((0.2 * 255).round())
                              : Colors.black.withAlpha((0.04 * 255).round()),
>>>>>>> add-font
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/illustration.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
<<<<<<< HEAD
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.03),
=======
                              ? Colors.black.withAlpha((0.3 * 255).round())
                              : Colors.black.withAlpha((0.03 * 255).round()),
>>>>>>> add-font
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? (isId
                                      ? 'Nama wajib diisi'
                                      : 'Name is required')
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
<<<<<<< HEAD
                              if (v == null || v.trim().isEmpty)
                                return isId
                                    ? 'Email wajib diisi'
                                    : 'Email is required';
                              if (!v.contains('@'))
                                return isId
                                    ? 'Email tidak valid'
                                    : 'Invalid email';
=======
                              if (v == null || v.trim().isEmpty) {
                                return isId
                                    ? 'Email wajib diisi'
                                    : 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return isId
                                    ? 'Email tidak valid'
                                    : 'Invalid email';
                              }
>>>>>>> add-font
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: InputDecoration(
                              labelText: isId ? 'Password' : 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: _obscure,
                            validator: (v) {
<<<<<<< HEAD
                              if (v == null || v.isEmpty)
                                return isId
                                    ? 'Password wajib diisi'
                                    : 'Password is required';
                              if (v.length < 6)
                                return isId
                                    ? 'Minimal 6 karakter'
                                    : 'Minimum 6 characters';
=======
                              if (v == null || v.isEmpty) {
                                return isId
                                    ? 'Password wajib diisi'
                                    : 'Password is required';
                              }
                              if (v.length < 6) {
                                return isId
                                    ? 'Minimal 6 karakter'
                                    : 'Minimum 6 characters';
                              }
>>>>>>> add-font
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmCtrl,
                            decoration: InputDecoration(
                              labelText: isId
                                  ? 'Konfirmasi Password'
                                  : 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                                icon: Icon(
                                  _obscure2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: _obscure2,
                            validator: (v) {
<<<<<<< HEAD
                              if (v == null || v.isEmpty)
                                return isId
                                    ? 'Konfirmasi password wajib diisi'
                                    : 'Confirm password is required';
                              if (v != _passwordCtrl.text)
                                return isId
                                    ? 'Password tidak cocok'
                                    : 'Passwords do not match';
=======
                              if (v == null || v.isEmpty) {
                                return isId
                                    ? 'Konfirmasi password wajib diisi'
                                    : 'Confirm password is required';
                              }
                              if (v != _passwordCtrl.text) {
                                return isId
                                    ? 'Password tidak cocok'
                                    : 'Passwords do not match';
                              }
>>>>>>> add-font
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(isId ? 'Daftar' : 'Register'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        isId
                            ? 'Sudah punya akun? '
                            : 'Already have an account? ',
<<<<<<< HEAD
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
=======
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
>>>>>>> add-font
                        ),
                      ),
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pushReplacementNamed(LoginScreen.routeName),
                        child: Text(
                          isId ? 'Login' : 'Sign In',
<<<<<<< HEAD
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
=======
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
>>>>>>> add-font
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
