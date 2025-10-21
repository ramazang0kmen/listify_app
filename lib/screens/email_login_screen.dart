import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listify_application/screens/email_register_screen.dart';
import 'package:provider/provider.dart';
import 'package:listify_application/stores/user_store.dart';
import 'package:listify_application/models/auth.dart';

class EmailLoginScreen extends StatefulWidget {
  static const route = '/email-login';
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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

    // Hataları snackbar ile göster
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
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    ),
                    const Spacer(),
                    const Text('E-posta ile Giriş',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('E-posta', Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'E-posta gerekli';
                        if (!v.contains('@')) return 'Geçerli bir e-posta gir';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Şifre
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('Şifre', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre gerekli';
                        if (v.length < 6) return 'En az 6 karakter';
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: store.loading ? null : () async {
                          if (_email.text.isEmpty || !_email.text.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Önce geçerli bir e-posta gir')),
                            );
                            return;
                          }
                          final ok = await context.read<UserStore>().sendPasswordReset(_email.text);
                          if (!mounted) return;
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi')),
                            );
                          }
                        },
                        child: const Text('Şifremi Unuttum'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: store.loading ? null : () async {
                          if (!_form.currentState!.validate()) return;
                          final ok = await context.read<UserStore>().signInWithEmail(
                                Auth(email: _email.text.trim(), password: _password.text),
                              );
                          if (!mounted) return;
                          if (ok) {
                            // TODO: Home ya da Username/Profile akışına yönlendir
                            // Navigator.pushReplacementNamed(context, HomeScreen.route);
                          }
                        },
                        child: store.loading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Giriş Yap'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kayıt yönlendirme
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Hesabın yok mu? ', style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, EmailRegisterScreen.route),
                          child: const Text('Kayıt Ol'),
                        )
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: _border(Colors.white24),
      focusedBorder: _border(Colors.white),
      errorBorder: _border(Colors.redAccent),
      focusedErrorBorder: _border(Colors.redAccent),
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
}
