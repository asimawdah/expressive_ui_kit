import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Data for a single expandable card in [MEExpandableList].
class MEExpandableData {
  const MEExpandableData({
    required this.title,
    this.subtitle,
    this.leading,
    required this.body,
    this.initiallyExpanded = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget body;
  final bool initiallyExpanded;
}

/// Expandable cards with expressive open/close motion.
///
/// Replaces stacked [ExpansionTile] lists. Cards morph from a pill into a
/// large-radius rectangle as they open.
class MEExpandableList extends StatelessWidget {
  const MEExpandableList({
    super.key,
    required this.data,
    this.gap = 8,
    this.padding,
  })  : scrollable = false,
        shrinkWrap = true,
        sliver = false;

  /// Scrollable variant for long lists.
  const MEExpandableList.scrollable({
    super.key,
    required this.data,
    this.gap = 8,
    this.padding,
    this.shrinkWrap = false,
  })  : scrollable = true,
        sliver = false;

  /// Sliver variant for a [CustomScrollView].
  const MEExpandableList.sliver({
    super.key,
    required this.data,
    this.gap = 8,
    this.padding,
  })  : scrollable = false,
        shrinkWrap = true,
        sliver = true;

  final List<MEExpandableData> data;
  final double gap;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool shrinkWrap;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      return SliverPadding(
        padding: padding ?? EdgeInsets.zero,
        sliver: SliverList.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => SizedBox(height: gap),
          itemBuilder: (context, i) => _MEExpandableCard(data: data[i]),
        ),
      );
    }

    final children = [
      for (var i = 0; i < data.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        _MEExpandableCard(data: data[i]),
      ],
    ];

    if (!scrollable) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
    }

    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

class _MEExpandableCard extends StatefulWidget {
  const _MEExpandableCard({required this.data});

  final MEExpandableData data;

  @override
  State<_MEExpandableCard> createState() => _MEExpandableCardState();
}

class _MEExpandableCardState extends State<_MEExpandableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController.unbounded(
    vsync: this,
    value: widget.data.initiallyExpanded ? 1 : 0,
  );
  late bool _expanded = widget.data.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    springTo(
      _anim,
      _expanded ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value.clamp(0.0, 1.2);
        final clamped = t.clamp(0.0, 1.0);
        final radius = 28.0 + (MECorners.large - 28.0) * clamped;
        return Material(
          color: Color.lerp(
            scheme.surfaceContainerLow,
            scheme.surfaceContainerHigh,
            clamped,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      if (widget.data.leading != null) ...[
                        widget.data.leading!,
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data.title,
                              style: textTheme.titleMedium,
                            ),
                            if (widget.data.subtitle != null)
                              Text(
                                widget.data.subtitle!,
                                style: textTheme.bodySmall!.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: clamped * 3.14159,
                        child: Icon(
                          Icons.expand_more,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: clamped,
                  child: Opacity(
                    opacity: clamped,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: DefaultTextStyle.merge(
                        style: textTheme.bodyMedium!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        child: widget.data.body,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
