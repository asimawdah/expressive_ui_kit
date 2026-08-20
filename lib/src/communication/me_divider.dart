import 'package:flutter/material.dart';

/// Axis for [MEDivider].
enum MEDividerAxis { horizontal, vertical }

/// A Material 3 Expressive divider.
///
/// Replaces [Divider] / [VerticalDivider]. M3 Expressive prefers "subhead"
/// dividers: a short, thick rounded segment rather than a full-width
/// hairline. Use [MEDivider.full] for a traditional full-width rule.
class MEDivider extends StatelessWidget {
  const MEDivider({
    super.key,
    this.indent = 0,
    this.axis = MEDividerAxis.horizontal,
  })  : _full = false,
        height = 32;

  const MEDivider.full({
    super.key,
    this.indent = 0,
    this.height = 16,
    this.axis = MEDividerAxis.horizontal,
  }) : _full = true;

  const MEDivider.vertical({
    super.key,
    this.indent = 0,
    this.height = 24,
  })  : axis = MEDividerAxis.vertical,
        _full = false;

  final double indent;
  final double height;
  final bool _full;
  final MEDividerAxis axis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.outlineVariant;

    if (axis == MEDividerAxis.vertical) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: height / 2, vertical: indent),
        child: Container(
          width: _full ? 1 : 4,
          height: _full ? double.infinity : 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_full ? 0 : 2),
          ),
        ),
      );
    }

    if (_full) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: indent, vertical: height / 2),
        child: Container(
          height: 1,
          color: color,
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
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
