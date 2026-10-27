import 'package:flutter/material.dart';

import '../markdown/me_markdown.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Position of a bubble within a run of consecutive messages from the same
/// sender, used to shape the "grouped" corners.
enum MEChatGroupPosition { single, first, middle, last }

/// A Material 3 Expressive chat message bubble.
///
/// * Outgoing bubbles use `primaryContainer`; incoming use
///   `surfaceContainerHigh`.
/// * The corner nearest the sender flattens for grouped messages,
///   following the M3E asymmetric-shape language.
/// * Bubbles pop in with a spatial spring (scale from the sender's side).
/// * Set [markdown] to true to render [text] with [MEMarkdown].
class MEChatBubble extends StatefulWidget {
  const MEChatBubble({
    super.key,
    required this.text,
    this.outgoing = false,
    this.markdown = false,
    this.position = MEChatGroupPosition.single,
    this.timestamp,
    this.avatar,
    this.onLinkTap,
    this.animateIn = true,
  });

  /// Message body (plain text, or markdown when [markdown] is true).
  final String text;

  /// True for messages sent by the local user (aligned to the trailing
  /// edge), false for received messages.
  final bool outgoing;

  /// Render the body with [MEMarkdown].
  final bool markdown;

  /// Corner grouping within a message run.
  final MEChatGroupPosition position;

  /// Optional timestamp label shown under the bubble.
  final String? timestamp;

  /// Optional leading avatar for incoming messages (typically shown only
  /// on the last bubble of a group).
  final Widget? avatar;

  /// Forwarded to [MEMarkdown.onLinkTap].
  final ValueChanged<String>? onLinkTap;

  /// Whether the bubble animates in when first built.
  final bool animateIn;

  @override
  State<MEChatBubble> createState() => _MEChatBubbleState();
}

class _MEChatBubbleState extends State<MEChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appear = AnimationController.unbounded(
    vsync: this,
    value: widget.animateIn ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animateIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          springTo(_appear, 1, METheme.of(context).motion.defaultSpatial);
        }
      });
    }
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  BorderRadius _radius() {
    const full = Radius.circular(MECorners.largeIncreased);
    const flat = Radius.circular(MECorners.extraSmall);

    // Flatten the corner on the sender's side for grouped bubbles.
    Radius top = full;
    Radius bottom = full;
    switch (widget.position) {
      case MEChatGroupPosition.single:
        break;
      case MEChatGroupPosition.first:
        bottom = flat;
      case MEChatGroupPosition.middle:
        top = flat;
        bottom = flat;
      case MEChatGroupPosition.last:
        top = flat;
    }

    return widget.outgoing
        ? BorderRadius.only(
            topLeft: full, bottomLeft: full, topRight: top, bottomRight: bottom)
        : BorderRadius.only(
            topRight: full,
            bottomRight: full,
            topLeft: top,
            bottomLeft: bottom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final background =
        widget.outgoing ? scheme.primaryContainer : scheme.surfaceContainerHigh;
    final foreground =
        widget.outgoing ? scheme.onPrimaryContainer : scheme.onSurface;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: background, borderRadius: _radius()),
      child: widget.markdown
          ? DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(color: foreground),
              child: MEMarkdown(data: widget.text, onLinkTap: widget.onLinkTap),
            )
          : Text(
              widget.text,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: foreground, height: 1.4),
            ),
    );

    final showAvatar = !widget.outgoing &&
        widget.avatar != null &&
        (widget.position == MEChatGroupPosition.single ||
            widget.position == MEChatGroupPosition.last);

    final column = Column(
      crossAxisAlignment:
          widget.outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        bubble,
        if (widget.timestamp != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.timestamp!,
              style: theme.textTheme.labelSmall!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );

    final row = Row(
      mainAxisAlignment:
          widget.outgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!widget.outgoing) ...[
          SizedBox(
            width: 36,
            child: showAvatar ? widget.avatar : null,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: column),
      ],
    );

    return AnimatedBuilder(
      animation: _appear,
      builder: (context, child) {
        final t = _appear.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.85 + 0.15 * t).clamp(0.0, 1.15),
            alignment:
                widget.outgoing ? Alignment.bottomRight : Alignment.bottomLeft,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}

/// A "typing" indicator bubble with three dots bouncing on a stagger,
/// driven by the expressive spatial spring feel.
class MEChatTypingIndicator extends StatefulWidget {
  const MEChatTypingIndicator({super.key});

  @override
  State<MEChatTypingIndicator> createState() => _MEChatTypingIndicatorState();
}

class _MEChatTypingIndicatorState extends State<MEChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Typing',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(MECorners.largeIncreased),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                // Staggered bounce: each dot delays by 0.15 of the cycle.
                final phase = (_controller.value - i * 0.15) % 1.0;
                final bounce = phase < 0.4
                    ? Curves.easeOutBack.transform(phase / 0.4) *
                        (1 - phase / 0.4)
                    : 0.0;
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  child: Transform.translate(
                    offset: Offset(0, -5 * bounce),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
