import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent;

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A command that can be searched and executed from [showMECommandPalette].
class MECommand {
  const MECommand({
    required this.label,
    this.icon,
    this.keywords = const [],
    this.shortcut,
    this.onSelected,
  });

  final String label;
  final IconData? icon;

  /// Extra search terms that match this command besides its label.
  final List<String> keywords;

  /// Optional shortcut hint rendered at the trailing edge (e.g. "Ctrl K").
  final String? shortcut;
  final VoidCallback? onSelected;

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    if (label.toLowerCase().contains(q)) return true;
    return keywords.any((k) => k.toLowerCase().contains(q));
  }
}

/// Shows a Material 3 Expressive command palette dialog.
///
/// A centered search field with a live-filtered command list. The panel
/// springs in with overshoot; arrow keys move the highlight and Enter
/// executes — the highlight pill springs between rows.
Future<void> showMECommandPalette(
  BuildContext context, {
  required List<MECommand> commands,
  String hintText = 'Type a command...',
}) {
  final motion = METheme.of(context).motion;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss command palette',
    barrierColor: Colors.black38,
    transitionDuration: motion.defaultSpatial.approximateDuration,
    pageBuilder: (context, _, __) =>
        _MECommandPalette(commands: commands, hintText: hintText),
    transitionBuilder: (context, animation, _, child) {
      final t = CurvedAnimation(
        parent: animation,
        curve: motion.defaultSpatial.curve,
      );
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: motion.defaultEffects.curve,
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(t),
          alignment: Alignment.topCenter,
          child: child,
        ),
      );
    },
  );
}

class _MECommandPalette extends StatefulWidget {
  const _MECommandPalette({required this.commands, required this.hintText});

  final List<MECommand> commands;
  final String hintText;

  @override
  State<_MECommandPalette> createState() => _MECommandPaletteState();
}

class _MECommandPaletteState extends State<_MECommandPalette> {
  final TextEditingController _controller = TextEditingController();
  int _highlighted = 0;

  List<MECommand> get _filtered =>
      widget.commands.where((c) => c.matches(_controller.text)).toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _execute(MECommand command) {
    Navigator.of(context).pop();
    command.onSelected?.call();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final filtered = _filtered;
    if (filtered.isEmpty) return KeyEventResult.ignored;
    switch (event.logicalKey.keyLabel) {
      case 'Arrow Down':
        setState(() => _highlighted = (_highlighted + 1) % filtered.length);
        return KeyEventResult.handled;
      case 'Arrow Up':
        setState(() => _highlighted =
            (_highlighted - 1 + filtered.length) % filtered.length);
        return KeyEventResult.handled;
      case 'Enter':
        _execute(filtered[_highlighted.clamp(0, filtered.length - 1)]);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    final filtered = _filtered;
    final highlighted = _highlighted.clamp(0, filtered.isEmpty ? 0 : filtered.length - 1);

    return Align(
      alignment: const Alignment(0, -0.6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 420),
          child: Material(
            color: scheme.surfaceContainerHigh,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MECorners.extraLarge),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Focus(
                  onKeyEvent: _onKey,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: (_) => setState(() => _highlighted = 0),
                    style: text.bodyLarge,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Flexible(
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No matching commands',
                            style: text.bodyMedium!.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final command = filtered[i];
                            final selected = i == highlighted;
                            return _CommandRow(
                              command: command,
                              selected: selected,
                              motion: motion,
                              onPressed: () => _execute(command),
                              onHover: () =>
                                  setState(() => _highlighted = i),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.command,
    required this.selected,
    required this.motion,
    required this.onPressed,
    required this.onHover,
  });

  final MECommand command;
  final bool selected;
  final MEMotionScheme motion;
  final VoidCallback onPressed;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: AnimatedContainer(
        duration: motion.fastSpatial.approximateDuration,
        curve: motion.fastSpatial.curve,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: ShapeDecoration(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              selected ? MECorners.large : MECorners.medium,
            ),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(MECorners.large),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (command.icon != null) ...[
                  Icon(
                    command.icon,
                    size: 20,
                    color: selected
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    command.label,
                    style: text.bodyMedium!.copyWith(
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (command.shortcut != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: ShapeDecoration(
                      color: scheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MECorners.extraSmall),
                      ),
                    ),
                    child: Text(
                      command.shortcut!,
                      style: text.labelSmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
