import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';
import 'me_text_field.dart';

/// A Material 3 Expressive autocomplete field.
///
/// Replaces [Autocomplete]. Combines an [METextField] with an expressive
/// options overlay: the options container scales in from the field with a
/// spatial spring and each option row uses full M3E state styling.
class MEAutocomplete<T extends Object> extends StatelessWidget {
  const MEAutocomplete({
    super.key,
    required this.optionsBuilder,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.onSelected,
    this.label,
    this.hintText,
    this.leadingIcon,
    this.maxOptionsHeight = 240,
  });

  /// Computes the options for the current text value.
  final AutocompleteOptionsBuilder<T> optionsBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final AutocompleteOnSelected<T>? onSelected;
  final String? label;
  final String? hintText;
  final Widget? leadingIcon;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      optionsBuilder: optionsBuilder,
      displayStringForOption: displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return METextField(
          controller: controller,
          focusNode: focusNode,
          label: label,
          hintText: hintText,
          leadingIcon: leadingIcon,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: _MEOptionsPanel<T>(
            options: options,
            onSelected: onSelected,
            displayStringForOption: displayStringForOption,
            maxHeight: maxOptionsHeight,
          ),
        );
      },
    );
  }
}

class _MEOptionsPanel<T extends Object> extends StatefulWidget {
  const _MEOptionsPanel({
    required this.options,
    required this.onSelected,
    required this.displayStringForOption,
    required this.maxHeight,
  });

  final Iterable<T> options;
  final AutocompleteOnSelected<T> onSelected;
  final AutocompleteOptionToString<T> displayStringForOption;
  final double maxHeight;

  @override
  State<_MEOptionsPanel<T>> createState() => _MEOptionsPanelState<T>();
}

class _MEOptionsPanelState<T extends Object> extends State<_MEOptionsPanel<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      springTo(_anim, 1, METheme.of(context).motion.fastSpatial);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value.clamp(0.0, 1.2);
        return Transform.scale(
          scale: 0.9 + 0.1 * t,
          alignment: AlignmentDirectional.topStart,
          child: Opacity(
            opacity: _anim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Material(
        color: colors.surfaceContainer,
        elevation: 6,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(MECorners.large),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight,
            maxWidth: 320,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options.elementAt(index);
              return InkWell(
                onTap: () => widget.onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    widget.displayStringForOption(option),
                    style: textTheme.bodyLarge!
                        .copyWith(color: colors.onSurface),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
