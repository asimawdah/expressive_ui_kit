import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/me_theme.dart';
import 'me_number_ticker.dart';

/// A Material 3 Expressive countdown timer.
///
/// Renders days/hours/minutes/seconds in pill-shaped cells whose digits
/// roll with the same spring as [MENumberTicker]. Calls [onFinished] when
/// the target time is reached.
class MECountdown extends StatefulWidget {
  const MECountdown({
    super.key,
    required this.target,
    this.onFinished,
    this.showDays = true,
    this.compact = false,
  });

  /// The moment counted down to.
  final DateTime target;

  final VoidCallback? onFinished;

  /// Whether to render the days cell (hidden automatically when zero and
  /// [compact] is true).
  final bool showDays;

  /// Smaller cells and typography.
  final bool compact;

  @override
  State<MECountdown> createState() => _MECountdownState();
}

class _MECountdownState extends State<MECountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(MECountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target) {
      _finished = false;
      _tick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final remaining = widget.target.difference(DateTime.now());
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
    if (remaining <= Duration.zero && !_finished) {
      _finished = true;
      widget.onFinished?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = (widget.compact ? text.titleLarge : text.headlineMedium)!
        .copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: scheme.onPrimaryContainer,
    );

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    final showDays = widget.showDays && (days > 0 || !widget.compact);

    final cells = <(int, String)>[
      if (showDays) (days, 'days'),
      (hours, 'hrs'),
      (minutes, 'min'),
      (seconds, 'sec'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 4 : 6,
              ),
              child: Text(
                ':',
                style: style.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          _Cell(
            value: cells[i].$1,
            label: cells[i].$2,
            style: style,
            compact: widget.compact,
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.value,
    required this.label,
    required this.style,
    required this.compact,
  });

  final int value;
  final String label;
  final TextStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 10,
          ),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
          ),
          child: MENumberTicker(
            value: value,
            padWidth: 2,
            style: style,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: text.labelSmall!.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
