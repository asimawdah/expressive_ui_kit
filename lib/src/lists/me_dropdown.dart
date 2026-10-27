import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';
import 'me_menu.dart';

/// A Material 3 Expressive dropdown field.
///
/// Replaces [DropdownButton] / [DropdownMenu]. Renders as a pill-shaped
/// field that opens an expressive spring-animated menu.
class MEDropdown<T> extends StatelessWidget {
  const MEDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final List<MEMenuItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = items.where((i) => i.value == value).toList();
    final display = selected.isEmpty ? null : selected.first;

    return MEMenuAnchor<T>(
      items: items,
      onSelected: enabled ? onChanged : (_) {},
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(MECorners.extraLarge),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  Text(
                    display?.label ?? 'Select',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: display == null
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
