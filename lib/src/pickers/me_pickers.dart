import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// Shows a Material 3 Expressive date picker.
///
/// Replaces [showDatePicker]. Wraps the Material date picker in expressive
/// theming: extra-large dialog corners, pill-shaped day/selection shapes
/// and a spring-curved entrance transition.
Future<DateTime?> showMEDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    builder: (context, child) => _MEPickerTheme(child: child!),
  );
}

/// Shows a Material 3 Expressive time picker.
///
/// Replaces [showTimePicker] with expressive theming.
Future<TimeOfDay?> showMETimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
    builder: (context, child) => _MEPickerTheme(child: child!),
  );
}

class _MEPickerTheme extends StatelessWidget {
  const _MEPickerTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final scheme = base.colorScheme;

    return Theme(
      data: base.copyWith(
        datePickerTheme: DatePickerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.extraLargeIncreased),
          ),
          backgroundColor: scheme.surfaceContainerHigh,
          dayShape: const WidgetStatePropertyAll(StadiumBorder()),
          todayBorder: BorderSide(color: scheme.primary, width: 1.5),
          headerHeadlineStyle: base.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.extraLargeIncreased),
          ),
          backgroundColor: scheme.surfaceContainerHigh,
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MECorners.large),
          ),
          dayPeriodShape: const StadiumBorder(),
          dialBackgroundColor: scheme.surfaceContainerHighest,
        ),
      ),
      child: child,
    );
  }
}
