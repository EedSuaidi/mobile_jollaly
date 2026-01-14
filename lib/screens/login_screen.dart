import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (!ok) {
      final msg = auth.error ?? 'Login gagal';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login berhasil')));
      // Ensure we leave the login route
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
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
                  // Feature bar (language + dark mode)
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
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Illustration placeholder box (replace with asset if available)
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/illustration.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // image set via decoration above
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

                  // Card-like form
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.03),
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
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return isId
                                    ? 'Email wajib diisi'
                                    : 'Email is required';
                              if (!v.contains('@'))
                                return isId
                                    ? 'Email tidak valid'
                                    : 'Invalid email';
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
                              if (v == null || v.isEmpty)
                                return isId
                                    ? 'Password wajib diisi'
                                    : 'Password is required';
                              if (v.length < 6)
                                return isId
                                    ? 'Minimal 6 karakter'
                                    : 'Minimum 6 characters';
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
                                : Text(isId ? 'Login' : 'Sign In'),
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
                            ? 'Belum punya akun? '
                            : 'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pushNamed(RegisterScreen.routeName),
                        child: Text(
                          isId ? 'Daftar' : 'Register',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
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
