// lib/screens/onboarding/onboarding_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listify_application/screens/auth_start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const route = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _ix = 0;

  static const _bg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
  );

  static const _headlineColors = [
    Color(0xFF7C4DFF),
    Color(0xFF40C4FF),
    Color(0xFF69F0AE),
    Color(0xFFFFEA00),
  ];

  Future<void> _setSeenAndGo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AuthStartScreen.route);
  }

  void _next() {
    if (_ix < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _setSeenAndGo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0D1B2A),
      systemNavigationBarIconBrightness: Brightness.light,
    );

    final pages = const [
      _OnbPage(
        icon: Icons.favorite_border,
        headline: 'Dilek Listeni Kur',
        sub: 'Almak istediklerini tek yerde topla, önceliklendir ve paylaş.',
      ),
      _OnbPage(
        icon: Icons.card_giftcard_outlined,
        headline: 'Paylaş & Rezerv Et',
        sub: 'Arkadaşların sürpriz yaparken çakışma olmasın, rezervleri gör.',
      ),
      _OnbPage(
        icon: Icons.image_search_outlined,
        headline: 'Görsel, Fiyat, Bağlantı',
        sub: 'Fotoğraflar ve linklerle netleştir. Fiyat görünürlüğünü sen seç.',
      ),
    ];

    final last = _ix == pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _bg),
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _setSeenAndGo,
                    child: const Text('Atla', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    onPageChanged: (i) => setState(() => _ix = i),
                    itemCount: pages.length,
                    itemBuilder: (_, i) => pages[i],
                  ),
                ),
                const SizedBox(height: 8),
                _Dots(count: pages.length, index: _ix),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D1B2A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _next,
                      child: Text(last ? 'Başla' : 'İleri'),
                    ),
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

class _OnbPage extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String sub;
  const _OnbPage({required this.icon, required this.headline, required this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 112, color: cs.onPrimary.withOpacity(0.95)),
          const SizedBox(height: 28),
          _GradientText(
            headline,
            colors: _OnboardingScreenState._headlineColors,
            tilt: 0.06 * math.pi,
            style: const TextStyle(
              fontFamily: 'Simplicity',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    const activeColor = Colors.white;
    const inactiveColor = Colors.white24;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

/// Statik gradyan başlık
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final double tilt; // radians
  final List<Shadow>? shadows;

  const _GradientText(
    this.text, {
    required this.style,
    required this.colors,
    required this.tilt,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final stops = List<double>.generate(colors.length, (i) => i / (colors.length - 1));
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
      stops: stops,
      transform: GradientRotation(tilt),
    );

    return ShaderMask(
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style.copyWith(color: Colors.white, shadows: shadows),
      ),
    );
  }
}
