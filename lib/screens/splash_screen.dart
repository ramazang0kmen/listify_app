// lib/screens/splash_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listify_application/screens/auth_start_screen.dart';
import 'package:listify_application/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _shift; // 0..1

  static const _kOnboardingSeenKey = 'onboarding_seen';

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _shift = CurvedAnimation(parent: _ac, curve: Curves.linear);

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Splash’ı biraz gösterelim
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_kOnboardingSeenKey) ?? false;

    if (!mounted) return;
    if (seen) {
      // Onboarding daha önce görüldüyse
      Navigator.of(context).pushReplacementNamed(AuthStartScreen.route);
      // Eğer login kontrolü eklemek istersen burada yapıp Home'a da yönlendirebilirsin.
    } else {
      Navigator.of(context).pushReplacementNamed(OnboardingScreen.route);
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
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

    const textColors = [
      Color(0xFF7C4DFF),
      Color(0xFF40C4FF),
      Color(0xFF69F0AE),
      Color(0xFFFFEA00),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bg),
          child: Center(
            child: AnimatedBuilder(
              animation: _shift,
              builder: (_, __) {
                return _GradientText(
                  'Listify',
                  style: const TextStyle(
                    fontFamily: 'Simplicity',
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  colors: textColors,
                  shift: _shift.value,
                  tilt: 0.06 * math.pi,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final double shift; // 0..1
  final double tilt;  // radyan
  final List<Shadow>? shadows;

  const _GradientText(
    this.text, {
    required this.style,
    required this.colors,
    required this.shift,
    required this.tilt,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final dx = (shift * 2.0 - 1.0); // -1..1
    final stops =
        List<double>.generate(colors.length, (i) => i / (colors.length - 1));

    final gradient = LinearGradient(
      begin: Alignment(-1 + dx, 0),
      end: Alignment(1 + dx, 0),
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
