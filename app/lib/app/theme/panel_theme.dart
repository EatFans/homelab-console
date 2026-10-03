import 'package:flutter/material.dart';

@immutable
class PanelPalette {
  const PanelPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.warning,
    required this.warningSurface,
    required this.floatingBar,
    required this.shadow,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color warning;
  final Color warningSurface;
  final Color floatingBar;
  final Color shadow;

  static const light = PanelPalette(
    canvas: Color(0xFFF5F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEBF0F4),
    text: Color(0xFF18232E),
    textMuted: Color(0xFF627180),
    border: Color(0xFFDCE4EA),
    accent: Color(0xFF2868B7),
    onAccent: Color(0xFFFFFFFF),
    warning: Color(0xFF985D12),
    warningSurface: Color(0xFFFFF1DC),
    floatingBar: Color(0xEEF9FBFD),
    shadow: Color(0x1A2F4354),
  );

  static const dark = PanelPalette(
    canvas: Color(0xFF121920),
    surface: Color(0xFF1D2832),
    surfaceMuted: Color(0xFF293642),
    text: Color(0xFFEDF3F7),
    textMuted: Color(0xFFA9B8C4),
    border: Color(0xFF3A4854),
    accent: Color(0xFF91C2FF),
    onAccent: Color(0xFF14283D),
    warning: Color(0xFFF1BF79),
    warningSurface: Color(0xFF3B3024),
    floatingBar: Color(0xEF202B35),
    shadow: Color(0x66000000),
  );

  static PanelPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

class PanelTheme {
  const PanelTheme._();

  static ThemeData get light => _build(PanelPalette.light, Brightness.light);
  static ThemeData get dark => _build(PanelPalette.dark, Brightness.dark);

  static ThemeData _build(PanelPalette palette, Brightness brightness) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: brightness,
        ).copyWith(
          primary: palette.accent,
          onPrimary: palette.onAccent,
          surface: palette.surface,
          onSurface: palette.text,
          outline: palette.border,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.text,
        elevation: 0,
      ),
    );
  }
}
