import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive data table.
///
/// Replaces [DataTable]. Wraps the standard table in the expressive
/// large-radius container with a tonal header row and no outer border.
class MEDataTable extends StatelessWidget {
  const MEDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onSelectAll,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final ValueSetter<bool?>? onSelectAll;
  final int? sortColumnIndex;
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(MECorners.large),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          onSelectAll: onSelectAll,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          headingRowColor: WidgetStatePropertyAll(colors.surfaceContainerHigh),
          headingTextStyle: textTheme.titleSmall!.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          dataTextStyle:
              textTheme.bodyMedium!.copyWith(color: colors.onSurface),
          dividerThickness: 0.5,
          horizontalMargin: 20,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
