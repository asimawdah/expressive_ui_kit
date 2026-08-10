import 'package:flutter/material.dart';

import '../buttons/me_icon_button.dart';
import '../internal/me_pressable.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive inline month calendar.
///
/// Replaces [CalendarDatePicker] for embedded use. The selected day is a
/// fully-round pill that morphs squarer on press (shape-as-state), today
/// is outlined, and month transitions slide with a spatial spring.
class MECalendar extends StatefulWidget {
  MECalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
  })  : firstDate = firstDate ?? DateTime(1900),
        lastDate = lastDate ?? DateTime(2100);

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<MECalendar> createState() => _MECalendarState();
}

class _MECalendarState extends State<MECalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _visibleMonth;

  /// -1 while sliding to the previous month, 1 to the next, 0 at rest.
  int _slideDirection = 0;
  late final AnimationController _slide =
      AnimationController.unbounded(vsync: this, value: 0);

  static const List<String> _weekdays = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _visibleMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    if (next.isBefore(
            DateTime(widget.firstDate.year, widget.firstDate.month)) ||
        next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      return;
    }
    setState(() {
      _visibleMonth = next;
      _slideDirection = delta.sign;
    });
    _slide.value = _slideDirection.toDouble();
    springTo(_slide, 0, METheme.of(context).motion.defaultSpatial);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Monday-first offset (DateTime.monday == 1).
    final leadingBlanks = firstOfMonth.weekday - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month header with navigation.
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Text(
                  '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
            MEIconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1),
            ),
            MEIconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Weekday header.
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: textTheme.labelSmall!
                        .copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Day grid, sliding on month change.
        ClipRect(
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, child) => FractionalTranslation(
              translation: Offset(_slide.value * 0.12, 0),
              child: Opacity(
                opacity: (1 - _slide.value.abs() * 0.6).clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: GridView.count(
              key: ValueKey('${_visibleMonth.year}-${_visibleMonth.month}'),
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _DayCell(
                    date:
                        DateTime(_visibleMonth.year, _visibleMonth.month, day),
                    selected: _sameDay(
                      DateTime(_visibleMonth.year, _visibleMonth.month, day),
                      widget.selectedDate,
                    ),
                    isToday: _sameDay(
                      DateTime(_visibleMonth.year, _visibleMonth.month, day),
                      today,
                    ),
                    enabled: !DateTime(
                                _visibleMonth.year, _visibleMonth.month, day)
                            .isBefore(widget.firstDate) &&
                        !DateTime(_visibleMonth.year, _visibleMonth.month, day)
                            .isAfter(widget.lastDate),
                    onPressed: widget.onDateSelected,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.enabled,
    required this.onPressed,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final bool enabled;
  final ValueChanged<DateTime> onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fg = !enabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : selected
            ? colors.onPrimary
            : isToday
                ? colors.primary
                : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: MEPressable(
        onPressed: enabled ? () => onPressed(date) : null,
        enabled: enabled,
        // Selected day: full pill. Press morphs squarer via the default
        // pressed shape, echoing shape-as-state.
        shape: selected
            ? const StadiumBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MECorners.medium),
                side: isToday
                    ? BorderSide(color: colors.primary)
                    : BorderSide.none,
              ),
        color: selected ? colors.primary : Colors.transparent,
        overlayColor: fg.withValues(alpha: 0.1),
        semanticLabel: '${date.day}',
        child: Center(
          child: Text(
            '${date.day}',
            style: textTheme.bodyMedium!.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}
