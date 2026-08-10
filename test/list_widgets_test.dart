import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

void main() {
  group('MEPaginatedDataTable', () {
    testWidgets('renders paginated rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: MEPaginatedDataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Value')),
              ],
              source: _SimpleSource(),
              rowsPerPage: 3,
              showCheckboxColumn: false,
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Row 0'), findsOneWidget);
      expect(find.byType(PaginatedDataTable), findsOneWidget);
    });
  });

  group('MEReorderableList', () {
    testWidgets('renders items with drag handles', (tester) async {
      final keys = [
        const ValueKey('a'),
        const ValueKey('b'),
        const ValueKey('c'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: MEReorderableList(
              keys: keys,
              onReorder: (_, __) {},
              itemBuilder: (context, index, position) => MEListTile(
                position: position,
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));
    });
  });
}

class _SimpleSource extends DataTableSource {
  @override
  DataRow? getRow(int index) {
    if (index >= 8) return null;
    return DataRow(
      cells: [
        DataCell(Text('Row $index')),
        DataCell(Text('Value $index')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => 8;

  @override
  int get selectedRowCount => 0;
}
