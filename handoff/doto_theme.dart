// DoTo — Spatial Glass
// Design tokens for the Flutter build. Generated from the prototype; values are
// logical pixels and match handoff/DESIGN_SPEC.md.

import 'dart:ui' show FontFeature, ImageFilter;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------- semantic

class DotoSemantic {
  static const priorityHigh = Color(0xFFC25E3D);
  static const priorityMedium = Color(0xFFF5C842);
  static const priorityLow = Color(0xFF57A11F);

  static const categoryWork = Color(0xFF004081);
  static const categoryPersonal = Color(0xFF00A9DC);
  static const categoryHealth = Color(0xFF57A11F);
  static const categoryHome = Color(0xFFF5C842);

  static const success = Color(0xFF57A11F); // streaks, completed progress, hero bar
  static const destructive = Color(0xFFC25E3D);
}

// ---------------------------------------------------------------- theme roles

@immutable
class DotoColors extends ThemeExtension<DotoColors> {
  final List<Color> backdrop; // 3 stops, 160deg
  final Color fg;
  final Color muted;
  final Color glass;
  final Color glassSecondary;
  final Color edge;
  final Color field;
  final Color accent;
  final Color onAccent;
  final Color pill; // selected tab / nav item background
  final Color onPill;
  final Color chip; // priority chip background

  const DotoColors({
    required this.backdrop,
    required this.fg,
    required this.muted,
    required this.glass,
    required this.glassSecondary,
    required this.edge,
    required this.field,
    required this.accent,
    required this.onAccent,
    required this.pill,
    required this.onPill,
    required this.chip,
  });

  static const light = DotoColors(
    backdrop: [Color(0xFFF7FAFC), Color(0xFFE6EEF5), Color(0xFFEDF3F7)],
    fg: Color(0xFF0A2543),
    muted: Color(0xA80A2543), // 66%
    glass: Color(0x75FFFFFF), // 46%
    glassSecondary: Color(0x4DFFFFFF), // 30%
    edge: Color(0x99FFFFFF), // 60%
    field: Color(0x99FFFFFF), // 60%
    accent: Color(0xFF004081),
    onAccent: Color(0xFFFFFFFF),
    pill: Color(0xFFFFFFFF),
    onPill: Color(0xFF004081),
    chip: Color(0x8CFFFFFF), // 55%
  );

  static const dark = DotoColors(
    backdrop: [Color(0xFF0B1219), Color(0xFF132836), Color(0xFF0F1D28)],
    fg: Color(0xFFF2F7FB),
    muted: Color(0xADF2F7FB), // 68%
    glass: Color(0x17FFFFFF), // 9%
    glassSecondary: Color(0x0FFFFFFF), // 6%
    edge: Color(0x29FFFFFF), // 16%
    field: Color(0x14FFFFFF), // 8%
    accent: Color(0xFF00A9DC),
    onAccent: Color(0xFF0B1219),
    pill: Color(0xEBFFFFFF), // 92%
    onPill: Color(0xFF0B1219),
    chip: Color(0x1AFFFFFF), // 10%
  );

  @override
  DotoColors copyWith({
    List<Color>? backdrop,
    Color? fg,
    Color? muted,
    Color? glass,
    Color? glassSecondary,
    Color? edge,
    Color? field,
    Color? accent,
    Color? onAccent,
    Color? pill,
    Color? onPill,
    Color? chip,
  }) =>
      DotoColors(
        backdrop: backdrop ?? this.backdrop,
        fg: fg ?? this.fg,
        muted: muted ?? this.muted,
        glass: glass ?? this.glass,
        glassSecondary: glassSecondary ?? this.glassSecondary,
        edge: edge ?? this.edge,
        field: field ?? this.field,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        pill: pill ?? this.pill,
        onPill: onPill ?? this.onPill,
        chip: chip ?? this.chip,
      );

  @override
  DotoColors lerp(ThemeExtension<DotoColors>? other, double t) {
    if (other is! DotoColors) return this;
    List<Color> lerpStops(List<Color> a, List<Color> b) =>
        List.generate(3, (i) => Color.lerp(a[i], b[i], t)!);
    return DotoColors(
      backdrop: lerpStops(backdrop, other.backdrop),
      fg: Color.lerp(fg, other.fg, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassSecondary: Color.lerp(glassSecondary, other.glassSecondary, t)!,
      edge: Color.lerp(edge, other.edge, t)!,
      field: Color.lerp(field, other.field, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      pill: Color.lerp(pill, other.pill, t)!,
      onPill: Color.lerp(onPill, other.onPill, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
    );
  }
}

// ---------------------------------------------------------------- geometry

class DotoRadius {
  static const device = 44.0;
  static const card = 26.0;
  static const sheet = 28.0;
  static const emptyState = 32.0;
  static const input = 18.0;
  static const row = 16.0;
  static const subtaskBox = 6.0;
  static const pill = 999.0;
}

class DotoSpace {
  static const screenH = 24.0;
  static const cardPadding = 17.0;
  static const panelPadding = 18.0;
  static const cardGap = 13.0;
  static const panelGap = 12.0;
  static const fieldGap = 18.0;

  static const navInset = 20.0;
  static const navBottom = 30.0;
  static const navHeight = 62.0;

  static const fabSize = 60.0;
  static const fabRight = 24.0;
  static const fabBottom = 104.0;

  /// Bottom scroll padding per screen — must clear the floating nav.
  static const scrollBottomHome = 190.0;
  static const scrollBottomAdd = 124.0;
  static const scrollBottomPanel = 120.0;
}

class DotoShadow {
  static const card = [BoxShadow(color: Color(0x170A2543), blurRadius: 28, offset: Offset(0, 10))];
  static const nav = [BoxShadow(color: Color(0x24004081), blurRadius: 30, offset: Offset(0, 12))];
  static const sheet = [BoxShadow(color: Color(0x1F004081), blurRadius: 34, offset: Offset(0, 14))];
  static const fab = [BoxShadow(color: Color(0x52004081), blurRadius: 32, offset: Offset(0, 14))];
  static const tabPill = [BoxShadow(color: Color(0x1A004081), blurRadius: 8, offset: Offset(0, 2))];
  static const save = [BoxShadow(color: Color(0x33004081), blurRadius: 28, offset: Offset(0, 12))];
  static const knob = [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))];
}

class DotoMotion {
  static const entry = Duration(milliseconds: 260);
  static const screen = Duration(milliseconds: 240);
  static const control = Duration(milliseconds: 180);
  static const toggle = Duration(milliseconds: 220);
  static const progress = Duration(milliseconds: 260);
  static const chart = Duration(milliseconds: 300);
  static const theme = Duration(milliseconds: 220);
  static const curve = Curves.ease;
}

// ---------------------------------------------------------------- type

/// Wire these to GoogleFonts.inter / GoogleFonts.jetBrainsMono, or to bundled
/// families named 'Inter' and 'JetBrains Mono'.
class DotoText {
  static const _tabular = [FontFeature.tabularFigures()];

  static const screenTitle = TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.9, height: 1.06);
  static const sectionTitle = TextStyle(fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.73, height: 1.15);
  static const addTitle = TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.2);
  static const cardTitle = TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.24, height: 1.35);
  static const panelTitle = TextStyle(fontFamily: 'Inter', fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: -0.22, height: 1.3);
  static const settingTitle = TextStyle(fontFamily: 'Inter', fontSize: 15.5, fontWeight: FontWeight.w600, letterSpacing: -0.23, height: 1.3);
  static const body = TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static const eyebrow = TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.88, height: 1.2);
  static const fieldLabel = TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, height: 1.2);
  static const categoryLabel = TextStyle(fontFamily: 'Inter', fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.74, height: 1.2);
  static const priorityChip = TextStyle(fontFamily: 'Inter', fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.63, height: 1.2);
  static const navLabel = TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.2);
  static const tabLabel = TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2);

  static const metaChip = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10.5, fontWeight: FontWeight.w400, height: 1.2, fontFeatures: _tabular);
  static const counter = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11.5, fontWeight: FontWeight.w400, height: 1.2, fontFeatures: _tabular);
  static const statNumber = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.68, height: 1.0, fontFeatures: _tabular);
  static const rateNumber = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 26, fontWeight: FontWeight.w700, height: 1.0, fontFeatures: _tabular);
}

// ---------------------------------------------------------------- helpers

/// The frosted surface used by cards, the nav bar, sheets and chips.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final double sigma;
  final EdgeInsets padding;
  final Color? fill;
  final List<BoxShadow> shadow;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius = DotoRadius.card,
    this.sigma = 10,
    this.padding = const EdgeInsets.all(DotoSpace.cardPadding),
    this.fill,
    this.shadow = DotoShadow.card,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>()!;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: shadow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fill ?? c.glass,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: c.edge, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Scaffold background: the 160° gradient plus the two ambient light blobs.
class DotoBackdrop extends StatelessWidget {
  final Widget child;
  const DotoBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>()!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.7, -1),
          end: const Alignment(0.7, 1),
          colors: c.backdrop,
          stops: const [0.0, 0.52, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.4, -0.4),
                    colors: [Color(0x8CFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(0.2, -0.2),
                    colors: [Color(0x2400A9DC), Color(0x0000A9DC)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

ThemeData dotoTheme({required bool dark}) {
  final c = dark ? DotoColors.dark : DotoColors.light;
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: c.backdrop.first,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(primary: c.accent, onPrimary: c.onAccent),
    extensions: [c],
  );
}
