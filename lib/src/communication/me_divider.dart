import 'package:flutter/material.dart';

/// A Material 3 Expressive divider.
///
/// Replaces [Divider]. M3 Expressive prefers "subhead" dividers: a short,
/// thick rounded segment rather than a full-width hairline. Use
/// [MEDivider.full] for a traditional full-width rule.
class MEDivider extends StatelessWidget {
  const MEDivider({super.key, this.indent = 0})
      : _full = false,
        height = 32;

  const MEDivider.full({super.key, this.indent = 0, this.height = 16})
      : _full = true;

  final double indent;
  final double height;
  final bool _full;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_full) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: indent, vertical: height / 2),
        child: Container(
          height: 1,
          color: scheme.outlineVariant,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 12, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: scheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
