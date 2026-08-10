import 'package:flutter/material.dart';

import '../theme/me_shapes.dart';

/// A Material 3 Expressive paginated data table.
///
/// Replaces [PaginatedDataTable]. Shares the same expressive container
/// styling as [MEDataTable]: large-radius surface, tonal header row, and
/// no outer border.
class MEPaginatedDataTable extends StatelessWidget {
  const MEPaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[5, 10, 20, 50, 100],
    this.sortColumnIndex,
    this.sortAscending = true,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
  });

  final List<DataColumn> columns;
  final DataTableSource source;
  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(MECorners.large),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dataTableTheme: DataTableThemeData(
            headingRowColor:
                WidgetStatePropertyAll(colors.surfaceContainerHigh),
            headingTextStyle: textTheme.titleSmall!.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            dataTextStyle:
                textTheme.bodyMedium!.copyWith(color: colors.onSurface),
            dividerThickness: 0.5,
            horizontalMargin: 20,
          ),
        ),
        child: PaginatedDataTable(
          columns: columns,
          source: source,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: availableRowsPerPage,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          showCheckboxColumn: showCheckboxColumn,
          showFirstLastButtons: showFirstLastButtons,
        ),
      ),
    );
  }
}
