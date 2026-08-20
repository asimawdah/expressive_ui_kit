import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// Inline dial-style time picker.
///
/// Complements [showMETimePicker] with an always-visible clock face. Drag
/// the hand to set hours, then minutes; tap AM/PM to toggle period.
class MEDialTimePicker extends StatefulWidget {
  const MEDialTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 256,
    this.use24HourFormat,
  });

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final double size;
  final bool? use24HourFormat;

  @override
  State<MEDialTimePicker> createState() => _MEDialTimePickerState();
}

class _MEDialTimePickerState extends State<MEDialTimePicker> {
  bool _selectingHour = true;

  bool get _use24h {
    return widget.use24HourFormat ??
        MediaQuery.alwaysUse24HourFormatOf(context);
  }

  void _setFromAngle(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = local - center;
    var angle = math.atan2(delta.dx, -delta.dy);
    if (angle < 0) angle += 2 * math.pi;
    final tick = (angle / (2 * math.pi) * 12).round() % 12;

    TimeOfDay next;
    if (_selectingHour) {
      final hour = _use24h
          ? tick + (widget.value.hour >= 12 ? 12 : 0)
          : (widget.value.period == DayPeriod.pm ? tick + 12 : tick) % 24;
      next = TimeOfDay(hour: hour % 24, minute: widget.value.minute);
    } else {
      next = TimeOfDay(hour: widget.value.hour, minute: (tick * 5) % 60);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hourLabel = widget.value.hourOfPeriod
        .toString()
        .padLeft(2, '0')
        .replaceFirst('00', '12');
    final minuteLabel = widget.value.minute.toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeDigit(
              text: _use24h
                  ? widget.value.hour.toString().padLeft(2, '0')
                  : hourLabel,
              selected: _selectingHour,
              onTap: () => setState(() => _selectingHour = true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                ':',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
            ),
            _TimeDigit(
              text: minuteLabel,
              selected: !_selectingHour,
              onTap: () => setState(() => _selectingHour = false),
            ),
            if (!_use24h) ...[
              const SizedBox(width: 12),
              Column(
                children: [
                  _PeriodChip(
                    label: 'AM',
                    selected: widget.value.period == DayPeriod.am,
                    onTap: () {
                      if (widget.value.period == DayPeriod.pm) {
                        widget.onChanged(TimeOfDay(
                          hour: widget.value.hour - 12,
                          minute: widget.value.minute,
                        ));
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  _PeriodChip(
                    label: 'PM',
                    selected: widget.value.period == DayPeriod.pm,
                    onTap: () {
                      if (widget.value.period == DayPeriod.am) {
                        widget.onChanged(TimeOfDay(
                          hour: widget.value.hour + 12,
                          minute: widget.value.minute,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onPanStart: (d) => _setFromAngle(d.localPosition),
          onPanUpdate: (d) => _setFromAngle(d.localPosition),
          onTapDown: (d) {
            _setFromAngle(d.localPosition);
            if (_selectingHour) {
              setState(() => _selectingHour = false);
            }
          },
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _DialPainter(
              value: widget.value,
              selectingHour: _selectingHour,
              use24h: _use24h,
              dialColor: scheme.surfaceContainerHighest,
              handColor: scheme.primary,
              onHandColor: scheme.onPrimary,
              labelColor: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeDigit extends StatelessWidget {
  const _TimeDigit({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MEPressable(
      onPressed: onTap,
      selected: selected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      selectedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.medium),
      ),
      color:
          selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MEPressable(
      onPressed: onTap,
      selected: selected,
      shape: const StadiumBorder(),
      color:
          selected ? scheme.tertiaryContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: selected ? scheme.onTertiaryContainer : scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.value,
    required this.selectingHour,
    required this.use24h,
    required this.dialColor,
    required this.handColor,
    required this.onHandColor,
    required this.labelColor,
  });

  final TimeOfDay value;
  final bool selectingHour;
  final bool use24h;
  final Color dialColor;
  final Color handColor;
  final Color onHandColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = dialColor);

    final labels = selectingHour
        ? (use24h
            ? const [
                '00',
                '2',
                '4',
                '6',
                '8',
                '10',
                '12',
                '14',
                '16',
                '18',
                '20',
                '22'
              ]
            : const [
                '12',
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '10',
                '11'
              ])
        : const [
            '00',
            '05',
            '10',
            '15',
            '20',
            '25',
            '30',
            '35',
            '40',
            '45',
            '50',
            '55'
          ];

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < 12; i++) {
      final angle = i / 12 * 2 * math.pi - math.pi / 2;
      final pos = Offset(
        center.dx + math.cos(angle) * (radius - 28),
        center.dy + math.sin(angle) * (radius - 28),
      );
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: labelColor, fontSize: 14),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final tick = selectingHour
        ? (use24h ? value.hour % 12 : value.hourOfPeriod % 12)
        : (value.minute / 5) % 12;
    final handAngle = tick / 12 * 2 * math.pi - math.pi / 2;
    final handEnd = Offset(
      center.dx + math.cos(handAngle) * (radius - 36),
      center.dy + math.sin(handAngle) * (radius - 36),
    );
    canvas.drawLine(
      center,
      handEnd,
      Paint()
        ..color = handColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 6, Paint()..color = handColor);
    canvas.drawCircle(handEnd, 22, Paint()..color = handColor);
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.selectingHour != selectingHour;
}
