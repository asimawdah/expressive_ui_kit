import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

import 'catalog.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key, required this.entry});

  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MEAppBar(
            title: Text(entry.name),
            subtitle: Text(
              entry.replaces == '—'
                  ? entry.category
                  : 'Replaces ${entry.replaces}',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            sliver: SliverToBoxAdapter(child: entry.demo(context)),
          ),
        ],
      ),
    );
  }
}
