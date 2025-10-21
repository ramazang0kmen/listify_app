// lib/components/auth/social_button.dart
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool inverted;
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = inverted ? Colors.white : Colors.white.withOpacity(0.08);
    final fg = inverted ? const Color(0xFF0D1B2A) : Colors.white;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          side: inverted ? const BorderSide(color: Colors.white24) : BorderSide.none,
        ),
      ),
    );
  }
}
