// Shared building blocks used by every module: aurora background,
// glass card, section header and stat tile.
//
// A "core widgets" file like this is the seed of a design system —
// screens compose these instead of re-styling Containers each time,
// which is what keeps 8 modules visually coherent. The Theming lab
// (seed colour + dark mode) re-skins all of them for free because
// they read colours from `Theme.of(context)` instead of hard-coding.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'tokens.dart';

// ------------------------------------------------------------------
// AuroraBackground — slow-drifting gradient blobs (pure CustomPaint).
//
// Used behind hero sections. It is *decorative*: wrapped in
// IgnorePointer and driven by a single repeating controller so it
// costs one repaint per frame at 60fps and zero layout work.
// ------------------------------------------------------------------
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, this.height = 380, this.opacity = 1.0});
  final double height;
  final double opacity;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          // AnimatedBuilder subscribes ONLY this subtree to the ticker —
          // the rest of the page never rebuilds, just repaints this paint.
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _AuroraPainter(
                t: _controller.value * 2 * math.pi,
                a: scheme.primary,
                b: scheme.tertiary,
                c: scheme.secondary,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(
      {required this.t, required this.a, required this.b, required this.c});
  final double t;
  final Color a, b, c;

  @override
  void paint(Canvas canvas, Size size) {
    // Base wash.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = a.withValues(alpha: 0.10),
    );
    // Three blobs orbit slowly; heavy blur fuses them into an aurora.
    void blob(double fx, double fy, double r, Color color, double phase) {
      final center = Offset(
        size.width * (fx + 0.08 * math.sin(t + phase)),
        size.height * (fy + 0.10 * math.cos(t * 0.8 + phase)),
      );
      canvas.drawCircle(
        center,
        size.shortestSide * r,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
      );
    }

    blob(0.18, 0.35, 0.55, a, 0);
    blob(0.82, 0.30, 0.50, b, 2.1);
    blob(0.55, 0.85, 0.55, c, 4.2);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

// ------------------------------------------------------------------
// GlassCard — bordered surface card with a soft tint. The "glass"
// comes from a translucent primary wash + outline border, which works
// in both light and dark mode without custom shaders.
// ------------------------------------------------------------------
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(Tokens.s16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Tokens.r16),
        color: scheme.surfaceContainerLow.withValues(alpha: 0.75),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: child,
    );
  }
}

// ------------------------------------------------------------------
// SectionHeader — eyebrow label + title + optional subtitle + action.
// Every module page opens with one, so all pages share a rhythm.
// ------------------------------------------------------------------
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.action = const SizedBox.shrink(),
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 350.ms),
              const SizedBox(height: Tokens.s4),
              Text(title, style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800))
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.15, end: 0),
              if (subtitle != null) ...[
                const SizedBox(height: Tokens.s4),
                Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        action,
      ],
    );
  }
}

// ------------------------------------------------------------------
// StatTile — icon + value + label. Used for KPI rows.
// ------------------------------------------------------------------
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    this.delta,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Tokens.s8),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Tokens.r12),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: Tokens.s12),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: theme.textTheme.bodySmall),
          if (delta != null) ...[
            const SizedBox(height: Tokens.s4),
            Text(delta!,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// MaxWidth — centres content and caps line length on wide screens.
// Every page wraps its body in this.
// ------------------------------------------------------------------
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: Tokens.maxContentWidth),
        child: child,
      ),
    );
  }
}
