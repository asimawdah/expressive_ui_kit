import 'package:flutter/material.dart';

import 'catalog.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key, required this.entry});

  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        children: [
          Text(
            entry.replaces == '—'
                ? entry.category
                : 'Replaces ${entry.replaces}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          entry.demo(context),
        ],
      ),
    );
  }
}
