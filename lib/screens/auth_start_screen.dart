// lib/screens/auth/auth_start_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listify_application/components/social_button.dart';
import 'package:listify_application/screens/email_login_screen.dart';
import 'package:listify_application/stores/user_store.dart';
import 'package:provider/provider.dart';

class AuthStartScreen extends StatefulWidget {
  static const route = '/auth-start';
  const AuthStartScreen({super.key});

  @override
  State<AuthStartScreen> createState() => _AuthStartScreenState();
}

class _AuthStartScreenState extends State<AuthStartScreen> {
  @override
  Widget build(BuildContext context) {
    const bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
    );

    final overlay = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0D1B2A),
      systemNavigationBarIconBrightness: Brightness.light,
    );

    final store = context.watch<UserStore>();

    // Hata mesajını snackbar ile göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = store.error;
      if (!mounted) return;
      if (err != null && err.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: bg),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Listify',
                    style: TextStyle(
                      fontFamily: 'Simplicity',
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hızlıca giriş yap ve listeni oluştur',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),

                  // Google
                  SocialButton(
                    onPressed: store.loading
                        ? null
                        : () async {
                            await context.read<UserStore>().signInWithGoogle();
                            if (!mounted) return;
                            if (context.read<UserStore>().isLoggedIn) {
                              // TODO: Username → Profil Foto → Home akışı
                              // Navigator.pushReplacementNamed(context, UsernameScreen.route);
                            }
                          },
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: 'Google ile Giriş',
                  ),
                  const SizedBox(height: 12),

                  // Email (şimdilik yönlendirme; passwordless akışı ayrı ekleyeceğiz)
                  SocialButton(
                    onPressed: store.loading
                        ? null
                        : () {
                            Navigator.pushNamed(context, EmailLoginScreen.route);
                          },
                    icon: const Icon(Icons.email_outlined, color: Color(0xFF0D1B2A)),
                    label: 'E-posta ile Giriş',
                    inverted: true,
                  ),

                  const SizedBox(height: 20),
                  if (store.loading) const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
