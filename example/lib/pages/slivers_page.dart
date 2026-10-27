import 'package:flutter/material.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

/// Demonstrates the sliver suite: flexible app bar, pinned header,
/// segmented sliver list and rounded sliver grid — all in one
/// CustomScrollView.
class SliversPage extends StatelessWidget {
  const SliversPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const MEAppBar(
          title: Text('Slivers'),
          subtitle: Text('Flexible large app bar'),
          size: MEAppBarSize.large,
          pinned: true,
        ),
        const MESliverSectionHeader(title: 'SEGMENTED LIST'),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: MESliverList(
            itemCount: 5,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: Text('Track ${index + 1}'),
              subtitle: const Text('MESliverList item'),
            ),
          ),
        ),
        const MESliverPinnedHeader(title: Text('PINNED HEADER')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: MESliverGrid(
            itemCount: 6,
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            itemBuilder: (context, index) => Container(
              color: scheme.surfaceContainerHigh,
              alignment: Alignment.center,
              child: Text('Tile ${index + 1}'),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
