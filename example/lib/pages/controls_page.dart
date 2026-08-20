import 'package:flutter/material.dart';
import 'package:material3_expressive/material3_expressive.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  double _slider = 0.4;
  RangeValues _range = const RangeValues(0.2, 0.7);
  bool _switch = true;
  bool _checkbox = true;
  int _radio = 0;

  @override
  Widget build(BuildContext context) {
    final TextStyle? title = Theme.of(context).textTheme.titleMedium;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Expressive slider', style: title),
        const SizedBox(height: 16),
        MESlider(
          value: _slider,
          onChanged: (v) => setState(() => _slider = v),
        ),
        const SizedBox(height: 32),
        Text('Range slider', style: title),
        const SizedBox(height: 16),
        MERangeSlider(
          values: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
        const SizedBox(height: 32),
        Text('Switch', style: title),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            MESwitch(
              value: _switch,
              onChanged: (v) => setState(() => _switch = v),
            ),
            const SizedBox(width: 16),
            Text(_switch ? 'On' : 'Off'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Checkbox', style: title),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            MECheckbox(
              value: _checkbox,
              onChanged: (v) => setState(() => _checkbox = v ?? false),
            ),
            const SizedBox(width: 16),
            Text(_checkbox ? 'Checked' : 'Unchecked'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Radio', style: title),
        const SizedBox(height: 8),
        Column(
          children: List<Widget>.generate(3, (i) {
            return Row(
              children: <Widget>[
                MERadio<int>(
                  value: i,
                  groupValue: _radio,
                  onChanged: (v) => setState(() => _radio = v),
                ),
                const SizedBox(width: 12),
                Text('Option ${i + 1}'),
              ],
            );
          }),
        ),
      ],
    );
  }
}
