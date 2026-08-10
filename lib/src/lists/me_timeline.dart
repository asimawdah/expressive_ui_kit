import 'package:flutter/material.dart';

/// One entry in an [METimeline].
class METimelineEntry {
  const METimelineEntry({
    required this.title,
    this.subtitle,
    this.icon,
    this.completed = false,
  });

  final Widget title;
  final Widget? subtitle;
  final IconData? icon;
  final bool completed;
}

/// A vertical activity timeline with expressive node styling: completed
/// nodes are filled primary circles, the active node is a larger tonal
/// ring, and connectors color-fill up to the active entry.
class METimeline extends StatelessWidget {
  const METimeline({
    super.key,
    required this.entries,
    this.activeIndex = 0,
  });

  final List<METimelineEntry> entries;

  /// Index of the current (in-progress) entry. Entries before it render
  /// as completed; entries after it as upcoming.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          _METimelineRow(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            state: i < activeIndex
                ? _MENodeState.completed
                : i == activeIndex
                    ? _MENodeState.active
                    : _MENodeState.upcoming,
            scheme: scheme,
            textTheme: textTheme,
          ),
      ],
    );
  }
}

enum _MENodeState { completed, active, upcoming }

class _METimelineRow extends StatelessWidget {
  const _METimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.state,
    required this.scheme,
    required this.textTheme,
  });

  final METimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final _MENodeState state;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = switch (state) {
      _MENodeState.completed => scheme.primary,
      _MENodeState.active => scheme.primaryContainer,
      _MENodeState.upcoming => scheme.surfaceContainerHigh,
    };
    final Color onNode = switch (state) {
      _MENodeState.completed => scheme.onPrimary,
      _MENodeState.active => scheme.onPrimaryContainer,
      _MENodeState.upcoming => scheme.onSurfaceVariant,
    };
    final bool lineAboveFilled =
        state == _MENodeState.completed || state == _MENodeState.active;
    final bool lineBelowFilled = state == _MENodeState.completed;
    final double nodeSize = state == _MENodeState.active ? 40 : 28;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Connector above the node.
                SizedBox(
                  height: 8,
                  child: isFirst
                      ? null
                      : _MEConnector(filled: lineAboveFilled, scheme: scheme),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    border: state == _MENodeState.active
                        ? Border.all(color: scheme.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    entry.icon ??
                        (state == _MENodeState.completed
                            ? Icons.check
                            : Icons.circle_outlined),
                    size: state == _MENodeState.active ? 20 : 16,
                    color: onNode,
                  ),
                ),
                // Connector below the node.
                Expanded(
                  child: isLast
                      ? const SizedBox.shrink()
                      : _MEConnector(filled: lineBelowFilled, scheme: scheme),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: textTheme.titleSmall!.copyWith(
                      color: state == _MENodeState.upcoming
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                    child: entry.title,
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: textTheme.bodySmall!
                          .copyWith(color: scheme.onSurfaceVariant),
                      child: entry.subtitle!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MEConnector extends StatelessWidget {
  const _MEConnector({required this.filled, required this.scheme});

  final bool filled;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: filled ? 3 : 2,
        decoration: BoxDecoration(
          color: filled ? scheme.primary : scheme.outlineVariant,
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }
}
