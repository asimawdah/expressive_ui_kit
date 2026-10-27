import 'package:flutter/material.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

class ContainersPage extends StatefulWidget {
  const ContainersPage({super.key});

  @override
  State<ContainersPage> createState() => _ContainersPageState();
}

class _ContainersPageState extends State<ContainersPage> {
  final Set<int> _selectedChips = <int>{0};

  @override
  Widget build(BuildContext context) {
    final TextStyle? title = Theme.of(context).textTheme.titleMedium;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Cards', style: title),
        const SizedBox(height: 16),
        MECard(
          onPressed: () {},
          child: const Text('Filled card - press me to feel the spring'),
        ),
        const SizedBox(height: 12),
        MECard.elevated(
          onPressed: () {},
          child: const Text('Elevated card'),
        ),
        const SizedBox(height: 12),
        MECard.outlined(
          onPressed: () {},
          child: const Text('Outlined card'),
        ),
        const SizedBox(height: 32),
        Text('Chips (selection morphs the shape)', style: title),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(4, (i) {
            final labels = <String>['Design', 'Motion', 'Shape', 'Color'];
            return MEChip(
              label: Text(labels[i]),
              selected: _selectedChips.contains(i),
              onPressed: () => setState(() {
                _selectedChips.contains(i)
                    ? _selectedChips.remove(i)
                    : _selectedChips.add(i);
              }),
            );
          }),
        ),
        const SizedBox(height: 32),
        Text('Dialog', style: title),
        const SizedBox(height: 16),
        MEButton.tonal(
          onPressed: () => showMEDialog<void>(
            context: context,
            builder: (context) => MEDialog(
              icon: const Icon(Icons.celebration_outlined),
              title: const Text('Expressive dialog'),
              content: const Text(
                'This dialog enters with a spring-driven scale and shape '
                'morph instead of a plain fade.',
              ),
              actions: <Widget>[
                MEButton.text(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                MEButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          child: const Text('Show dialog'),
        ),
      ],
    );
  }
}
