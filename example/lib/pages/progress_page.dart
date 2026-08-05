import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) {
    // The whole page is pull-to-refresh via MERefreshIndicator, which
    // uses the expressive shape-morphing loading indicator.
    return MERefreshIndicator(
      onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Pull down to see MERefreshIndicator',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 32),
        Text('Wavy linear (determinate)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        MELinearProgressIndicator(value: _value),
        const SizedBox(height: 16),
        MESlider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        const SizedBox(height: 32),
        Text('Wavy linear (indeterminate)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const MELinearProgressIndicator(),
        const SizedBox(height: 32),
        Text('Wavy circular',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            MECircularProgressIndicator(value: _value),
            const SizedBox(width: 32),
            const MECircularProgressIndicator(),
          ],
        ),
        const SizedBox(height: 32),
        Text('Loading indicator (shape morphing)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const Row(
          children: <Widget>[
            MELoadingIndicator(),
            SizedBox(width: 32),
            MELoadingIndicator(contained: true),
          ],
        ),
      ],
      ),
    );
  }
}
