import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listify_application/services/image_upload_service.dart';
import 'package:provider/provider.dart';
import 'package:listify_application/stores/user_store.dart';
import 'package:listify_application/models/auth.dart';
import 'package:listify_application/services/user_service.dart';

class EmailRegisterScreen extends StatefulWidget {
  static const route = '/email-register';
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final _pc = PageController();
  int _ix = 0;

  // Step 1
  final _form1 = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  // Step 2
  final _form2 = GlobalKey<FormState>();
  final _username = TextEditingController();

  // Step 3
  XFile? _picked;
  bool _uploading = false;

  @override
  void dispose() {
    _pc.dispose();
    _email.dispose();
    _password.dispose();
    _username.dispose();
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

    final last = _ix == 2;

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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      ),
                      const Spacer(),
                      Text('${_ix + 1}/3', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView(
                      controller: _pc,
                      physics: const NeverScrollableScrollPhysics(), // butonla ilerletiyoruz
                      onPageChanged: (i) => setState(() => _ix = i),
                      children: [
                        _stepEmailPassword(),
                        _stepUsername(),
                        _stepPhoto(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: store.loading || _uploading ? null : () async {
                        if (_ix == 0) {
                          if (!_form1.currentState!.validate()) return;
                          // Signup (Auth + Firestore garantisi store'da var)
                          final ok = await context.read<UserStore>().signUpWithEmail(
                                Auth(email: _email.text.trim(), password: _password.text),
                              );
                          if (ok) {
                            _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                          }
                        } else if (_ix == 1) {
                          if (!_form2.currentState!.validate()) return;
                          _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        } else {
                          // Finish: foto varsa yükle, username & photoUrl Firestore'a yaz
                          await _completeProfile();
                        }
                      },
                      child: (store.loading || _uploading)
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(last ? 'Bitir' : 'Devam'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 1: Email / Password
  Widget _stepEmailPassword() {
    return Form(
      key: _form1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _field(
            controller: _email,
            label: 'E-posta',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'E-posta gerekli';
              if (!v.contains('@')) return 'Geçerli bir e-posta gir';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _password,
            label: 'Şifre',
            icon: Icons.lock_outline,
            obscure: true,
            trailing: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Şifre gerekli';
              if (v.length < 6) return 'En az 6 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // --- Step 2: Username
  Widget _stepUsername() {
    return Form(
      key: _form2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Kullanıcı Adı', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _field(
            controller: _username,
            label: 'Kullanıcı adı',
            icon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kullanıcı adı gerekli';
              if (v.length < 3) return 'En az 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 8),
          const Text('Daha sonra ayarlardan değiştirebilirsin.',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // --- Step 3: Photo
  Widget _stepPhoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Profil Fotoğrafı', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 56,
            backgroundColor: Colors.white24,
            backgroundImage: (_picked != null) ? FileImage(File(_picked!.path)) : null,
            child: (_picked == null)
                ? const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 32)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Dokunarak galeri seç', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) setState(() => _picked = img);
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? trailing,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure && (_obscure),
      style: const TextStyle(color: Colors.white),
      decoration: _dec(label, icon).copyWith(suffixIcon: trailing),
      validator: validator,
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  Future<void> _completeProfile() async {
    final store = context.read<UserStore>();
    final user = store.fbUser; // FirebaseAuth kullanıcısı
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Önce giriş/kayıt olmalısın.')));
      return;
    }

    String? photoUrl;

    // Foto seçildiyse Storage'a yükle
    if (_picked != null) {
  try {
    setState(() => _uploading = true);
    photoUrl = await ImageUploadService.instance.upload(_picked!);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto yüklenemedi: $e')),
    );
  } finally {
    if (mounted) setState(() => _uploading = false);
  }
}

    // Firestore profilini güncelle (displayName + photoUrl)
    try {
      await UserService.instance.updateUser(
        user.uid, // not: UserService doküman id’yi Firestore oluşturuyordu. 
                  // Eğer doc id = auth uid olsun istiyorsan UserService'i buna göre değiştir.
        displayName: _username.text.trim().isEmpty ? null : _username.text.trim(),
        profilePictureUrl: photoUrl,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil güncellenemedi: $e')));
      return;
    }

    if (!mounted) return;
    // TODO: Home'a yönlendir
    // Navigator.pushReplacementNamed(context, HomeScreen.route);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt tamamlandı!')));
    Navigator.pop(context); // Geçici: geri dön
  }
}
