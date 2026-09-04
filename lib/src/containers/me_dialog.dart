import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../buttons/me_button.dart';
import '../inputs/me_text_field.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive dialog.
///
/// Replaces [AlertDialog]. Uses the expressive extra-large container
/// shape. Show it with [showMEDialog] for the spring-scale entrance.
class MEDialog extends StatelessWidget {
  const MEDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final maxHeight = (media.size.height - media.viewInsets.bottom) * 0.9;

    return Dialog(
      backgroundColor: colors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: icon != null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(size: 24, color: colors.secondary),
                  child: icon!,
                ),
                const SizedBox(height: 16),
              ],
              if (title != null) ...[
                DefaultTextStyle.merge(
                  style: textTheme.headlineSmall!.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: icon != null ? TextAlign.center : TextAlign.start,
                  child: title!,
                ),
                const SizedBox(height: 16),
              ],
              if (content != null)
                Flexible(
                  child: SingleChildScrollView(
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodyMedium!
                          .copyWith(color: colors.onSurfaceVariant),
                      child: content!,
                    ),
                  ),
                ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a full-screen dialog with a spring slide-up entrance.
Future<T?> showMEFullScreenDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget body,
  List<Widget> actions = const [],
  Widget? leading,
}) {
  final motion = METheme.of(context).motion;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: motion.defaultSpatial.approximateDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      final scheme = Theme.of(context).colorScheme;
      return Material(
        color: scheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    leading ??
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.titleLarge!,
                        child: title,
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: motion.defaultSpatial.curve,
        reverseCurve: motion.fastSpatial.curve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Selection list dialog; confirm is disabled until a choice is made.
Future<List<T>?> showMESelectionDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  String Function(T value)? labelBuilder,
  bool multiSelect = false,
  Set<T>? initialSelection,
}) {
  return showMEDialog<List<T>>(
    context: context,
    builder: (context) => _MESelectionDialog<T>(
      title: title,
      options: options,
      labelBuilder: labelBuilder ?? (v) => '$v',
      multiSelect: multiSelect,
      initialSelection: initialSelection ?? <T>{},
    ),
  );
}

class _MESelectionDialog<T> extends StatefulWidget {
  const _MESelectionDialog({
    required this.title,
    required this.options,
    required this.labelBuilder,
    required this.multiSelect,
    required this.initialSelection,
  });

  final String title;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final bool multiSelect;
  final Set<T> initialSelection;

  @override
  State<_MESelectionDialog<T>> createState() => _MESelectionDialogState<T>();
}

class _MESelectionDialogState<T> extends State<_MESelectionDialog<T>> {
  late Set<T> _selected = Set<T>.from(widget.initialSelection);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MEDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in widget.options)
                ListTile(
                  title: Text(widget.labelBuilder(option)),
                  selected: _selected.contains(option),
                  selectedTileColor: scheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MECorners.large),
                  ),
                  onTap: () => setState(() {
                    if (widget.multiSelect) {
                      if (!_selected.remove(option)) _selected.add(option);
                    } else {
                      _selected = {option};
                    }
                  }),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Single-line text prompt. Owns its [TextEditingController] for the
/// lifetime of the route so the field cannot outlive or be disposed
/// before the overlay.
Future<String?> showMEInputDialog({
  required BuildContext context,
  required String title,
  String? label,
  String? hintText,
  String initialText = '',
  Widget? icon,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool autofocus = true,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  List<TextInputFormatter>? inputFormatters,
}) {
  return showMEDialog<String>(
    context: context,
    builder: (context) => _MEInputDialog(
      title: title,
      label: label,
      hintText: hintText,
      initialText: initialText,
      icon: icon,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
    ),
  );
}

class _MEInputDialog extends StatefulWidget {
  const _MEInputDialog({
    required this.title,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.initialText,
    required this.autofocus,
    this.label,
    this.hintText,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  final String title;
  final String? label;
  final String? hintText;
  final String initialText;
  final Widget? icon;
  final String cancelLabel;
  final String confirmLabel;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_MEInputDialog> createState() => _MEInputDialogState();
}

class _MEInputDialogState extends State<_MEInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return MEDialog(
      icon: widget.icon,
      title: Text(widget.title),
      content: METextField(
        controller: _controller,
        label: widget.label,
        hintText: widget.hintText,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction ?? TextInputAction.done,
        inputFormatters: widget.inputFormatters,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        MEButton.text(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        MEButton.filled(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Shows an [MEDialog] with the M3 Expressive spring-scale entrance
/// transition. Replaces [showDialog] for dialogs.
Future<T?> showMEDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  ThemeData? theme,
}) {
  final motion = METheme.of(context).motion;
  final overlayTheme = theme ?? Theme.of(context);
  final overlayMeTheme = METheme.of(context);
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: motion.defaultSpatial.approximateDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Theme(
        data: overlayTheme,
        child: METheme(
          data: overlayMeTheme,
          child: SafeArea(
            child: Center(child: builder(context)),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: motion.defaultSpatial.curve,
        reverseCurve: motion.fastSpatial.curve,
      );
      final fade = CurvedAnimation(
        parent: animation,
        curve: motion.defaultEffects.curve,
        reverseCurve: motion.fastEffects.curve,
      );
      return AnimatedBuilder(
        animation: fade,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(scale),
          child: child,
        ),
        builder: (context, child) {
          return Opacity(
            opacity: fade.value.clamp(0.0, 1.0),
            child: child,
          );
        },
      );
    },
  );
}
