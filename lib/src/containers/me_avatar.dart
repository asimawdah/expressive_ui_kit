import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';

/// A Material 3 Expressive avatar.
///
/// Replaces [CircleAvatar]. Rests as a circle; when [onPressed] is set the
/// avatar becomes interactive and morphs toward a rounded square while
/// pressed — the M3E press-morph signal. When [selected] is true it stays
/// in the squarer shape and shows a selection ring, matching the avatar
/// selection pattern in expressive Google apps.
class MEAvatar extends StatelessWidget {
  const MEAvatar({
    super.key,
    this.image,
    this.child,
    this.onPressed,
    this.selected = false,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
  }) : assert(image == null || child == null,
            'Provide either an image or a child, not both.');

  /// Avatar image, painted with [BoxFit.cover].
  final ImageProvider? image;

  /// Fallback content: initials or an icon.
  final Widget? child;
  final VoidCallback? onPressed;
  final bool selected;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colors.primaryContainer;
    final fg = foregroundColor ?? colors.onPrimaryContainer;

    Widget content = SizedBox(
      width: size,
      height: size,
      child: image != null
          ? Ink(
              decoration: BoxDecoration(
                image: DecorationImage(image: image!, fit: BoxFit.cover),
              ),
            )
          : Center(
              child: IconTheme.merge(
                data: IconThemeData(color: fg, size: size * 0.5),
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: fg,
                        fontSize: size * 0.4,
                      ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
    );

    content = MEPressable(
      onPressed: onPressed,
      enabled: onPressed != null,
      shape: const CircleBorder(),
      // Press/selection morphs to a rounded square.
      pressedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      selectedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      selected: selected,
      color: bg,
      overlayColor: fg.withValues(alpha: 0.1),
      semanticLabel: semanticLabel,
      child: content,
    );

    if (!selected) return content;

    // Selection ring, offset from the avatar edge.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3 + 4),
        border: Border.all(color: colors.primary, width: 2),
      ),
      child: content,
    );
  }
}

/// A row of overlapping [MEAvatar]s.
///
/// New in the expressive idiom: compactly represents a group of people.
class MEAvatarGroup extends StatelessWidget {
  const MEAvatarGroup({
    super.key,
    required this.avatars,
    this.size = 40,
    this.overlap = 0.3,
    this.max = 4,
  });

  final List<MEAvatar> avatars;
  final double size;

  /// Fraction of each avatar hidden behind the previous one (0..1).
  final double overlap;

  /// Maximum avatars shown before collapsing into a "+N" overflow avatar.
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visible = avatars.length <= max ? avatars.length : max - 1;
    final overflow = avatars.length - visible;
    final step = size * (1 - overlap);

    return SizedBox(
      height: size,
      width: step * (visible + (overflow > 0 ? 1 : 0)) + size * overlap,
      child: Stack(
        children: [
          for (int i = 0; i < visible; i++)
            Positioned(
              left: step * i,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surface,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: avatars[i],
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: step * visible,
              child: MEAvatar(
                size: size,
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurfaceVariant,
                child: Text('+$overflow'),
              ),
            ),
        ],
      ),
    );
  }
}
