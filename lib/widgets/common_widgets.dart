import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ── PrimaryButton ─────────────────────────────────────────────────────────────
/// A confident, flat, solid-fill CTA button with a subtle top highlight and a
/// tactile press animation. This is the app's single loudest action style —
/// used sparingly so it keeps its weight.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = SplitsColors.primary,
    this.width,
    this.height = 52,
    this.borderRadius = SplitsRadius.md,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.disabled = false,
    this.glow = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final bool disabled;
  final bool glow;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effective = widget.disabled ? null : widget.onPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        effective?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.disabled ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.disabled ? SplitsColors.darkSurfaceHigh : widget.color,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.disabled || !widget.glow
                  ? []
                  : [
                      BoxShadow(
                        color: widget.color.withOpacity(0.34),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            // Chrome sheen painted OVER the child. Using foregroundDecoration
            // (not a Stack) keeps the button shrink-wrapped to its content —
            // an expanding Stack would stretch it to the full parent width.
            foregroundDecoration: widget.disabled
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ── GhostButton ───────────────────────────────────────────────────────────────
/// Secondary action: outlined, no fill — used when a screen already has a
/// PrimaryButton and needs a quieter companion action.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.height = 44,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = color ?? p.textPrimary;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: p.borderStrong),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SplitsRadius.md)),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: c),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: c)),
          ],
        ),
      ),
    );
  }
}

// ── PillButton ────────────────────────────────────────────────────────────────
/// A small solid pill button used inline in list headers ("+ Add Item").
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = SplitsColors.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SplitsRadius.pill),
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(SplitsRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: SplitsColors.onGold),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: SplitsColors.onGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AppIconButton ─────────────────────────────────────────────────────────────
/// Flat circular icon button used in app bars / list actions.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: p.surfaceRaised,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.46, color: p.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ── AppCard ───────────────────────────────────────────────────────────────────
/// The base flat elevated surface used everywhere: hairline border, no
/// gradient noise, optional tap ripple.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = SplitsRadius.lg,
    this.color,
    this.borderColor,
    this.onTap,
    this.raised = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fill = color ?? (raised ? p.surfaceRaised : p.surface);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? p.border, width: 1),
      ),
      child: child,
    );

    if (onTap == null) {
      return Padding(padding: margin, child: content);
    }

    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!();
          },
          child: content,
        ),
      ),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(0, 24, 0, 12),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: SplitsColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: p.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── EmptyState ────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.tone = Tone.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fg = tone.text(p);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tone.base().withOpacity(p.tint),
                shape: BoxShape.circle,
                border: Border.all(
                    color: tone.base().withOpacity(p.isDark ? 0.24 : 0.28),
                    width: 1.5),
              ),
              child: Icon(icon, color: fg, size: 30),
            ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: p.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.size = 40,
    this.ring = false,
    this.ringColor,
  });

  final String name;
  final double size;
  final bool ring;
  final Color? ringColor;

  static const _gradients = [
    [Color(0xFF16C2B0), Color(0xFF6FEFDD)],
    [Color(0xFF22D68A), Color(0xFF6FF0BB)],
    [Color(0xFFFF6B9D), Color(0xFFFFB3D1)],
    [Color(0xFFFF8C42), Color(0xFFFFCC80)],
    [Color(0xFF3EC6FF), Color(0xFF90E8FF)],
  ];

  @override
  Widget build(BuildContext context) {
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % _gradients.length : 0;
    final colors = _gradients[idx];
    final initials = _initials(name);

    return Container(
      width: size,
      height: size,
      padding: ring ? const EdgeInsets.all(2) : EdgeInsets.zero,
      decoration: ring
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor ?? SplitsColors.primary, width: 2),
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.34,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ── StatusPill ────────────────────────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final Tone tone;
  final IconData? icon;

  factory StatusPill.paid() => const StatusPill(
        label: 'Paid',
        tone: Tone.positive,
        icon: Icons.check_circle_rounded,
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fg = tone.text(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tone.base().withOpacity(p.tint),
        borderRadius: BorderRadius.circular(SplitsRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AmountBadge ───────────────────────────────────────────────────────────────
/// A flat, bold amount pill (e.g. item price on a card).
class AmountBadge extends StatelessWidget {
  const AmountBadge({
    super.key,
    required this.amount,
    required this.currency,
    this.color = SplitsColors.primary,
    this.filled = true,
  });

  final double amount;
  final String currency;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SplitsRadius.sm),
      ),
      child: Text(
        '$currency${amount.toStringAsFixed(2)}',
        style: amountStyle(
          size: 13,
          weight: FontWeight.w800,
          color: filled ? SplitsColors.onGold : color,
        ),
      ),
    );
  }
}

// ── StatChip ──────────────────────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final color = highlight ? p.positiveText : p.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? SplitsColors.positive.withOpacity(p.tint)
            : p.surfaceRaised,
        borderRadius: BorderRadius.circular(SplitsRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              height: 1.1,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SelectableChip ────────────────────────────────────────────────────────────
/// A pill chip used for member/currency selection in forms.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 150.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? SplitsColors.primary : p.surfaceRaised,
          borderRadius: BorderRadius.circular(SplitsRadius.pill),
          border: Border.all(
            color: selected ? SplitsColors.primary : p.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(
                color: selected ? SplitsColors.onGold : p.textPrimary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
  }
}

// ── SheetHandle ───────────────────────────────────────────────────────────────
/// The small grab-handle bar at the top of every bottom sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: p.borderStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── CountBadge ────────────────────────────────────────────────────────────────
/// Small neutral pill showing a count, used on the right of a SectionHeader.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(SplitsRadius.pill),
        border: Border.all(color: p.border),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: p.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.2,
        ),
      ),
    );
  }
}

// ── FieldLabel ────────────────────────────────────────────────────────────────
/// Consistent small label above a form control.
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
          color: p.textSecondary,
        ),
      ),
    );
  }
}

// ── SheetScaffold ─────────────────────────────────────────────────────────────
/// Shared chrome for every modal bottom sheet: rounded top, grab handle,
/// title, keyboard-aware padding, and scrolling when content is tall.
///
/// Centralising this keeps sheet padding identical everywhere and prevents a
/// tall sheet (many members, small screen) from overflowing.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const SheetHandle(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: p.surfaceRaised,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 17, color: p.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FormError ─────────────────────────────────────────────────────────────────
class FormError extends StatelessWidget {
  const FormError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: SplitsColors.negative),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: SplitsColors.negative, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
