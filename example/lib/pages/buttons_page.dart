import 'package:flutter/material.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _iconSelected = false;
  Set<int> _groupSelection = <int>{0};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        const _SectionLabel('Variants'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            MEButton.filled(onPressed: () {}, child: const Text('Filled')),
            MEButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            MEButton.elevated(onPressed: () {}, child: const Text('Elevated')),
            MEButton.outlined(onPressed: () {}, child: const Text('Outlined')),
            MEButton.text(onPressed: () {}, child: const Text('Text')),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionLabel('Sizes'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            MEButton.filled(
              size: MEButtonSize.extraSmall,
              onPressed: () {},
              child: const Text('XS'),
            ),
            MEButton.filled(
              size: MEButtonSize.small,
              onPressed: () {},
              child: const Text('Small'),
            ),
            MEButton.filled(
              size: MEButtonSize.medium,
              onPressed: () {},
              child: const Text('Medium'),
            ),
            MEButton.filled(
              size: MEButtonSize.large,
              onPressed: () {},
              child: const Text('Large'),
            ),
            MEButton.filled(
              size: MEButtonSize.extraLarge,
              onPressed: () {},
              child: const Text('XL'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionLabel('Icon buttons (toggle to see shape morph)'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            MEIconButton(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              selected: _iconSelected,
              onPressed: () => setState(() => _iconSelected = !_iconSelected),
            ),
            MEIconButton(
              variant: MEButtonVariant.filled,
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
            MEIconButton(
              variant: MEButtonVariant.outlined,
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionLabel('Button group (connected)'),
        MEButtonGroup(
          style: MEButtonGroupStyle.connected,
          selectedIndices: _groupSelection,
          onSelectionChanged: (s) => setState(() => _groupSelection = s),
          items: const <MEButtonGroupItem>[
            MEButtonGroupItem(child: Text('Day')),
            MEButtonGroupItem(child: Text('Week')),
            MEButtonGroupItem(child: Text('Month')),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Button group (standard, neighbors compress)'),
        MEButtonGroup(
          items: <MEButtonGroupItem>[
            MEButtonGroupItem(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
              child: const Text('Edit'),
            ),
            MEButtonGroupItem(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
              child: const Text('Share'),
            ),
            MEButtonGroupItem(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {},
              child: const Text('Delete'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionLabel('Split button'),
        MESplitButton(
          onPressed: () {},
          menuItems: <MenuItemButton>[
            MenuItemButton(
              leadingIcon: const Icon(Icons.drafts_outlined),
              onPressed: () {},
              child: const Text('Save as draft'),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.copy_outlined),
              onPressed: () {},
              child: const Text('Save a copy'),
            ),
          ],
          child: const Text('Save'),
        ),
        const SizedBox(height: 32),
        const _SectionLabel('FABs'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            MEFab(
              size: MEFabSize.small,
              onPressed: () {},
              icon: const Icon(Icons.edit),
            ),
            MEFab(onPressed: () {}, icon: const Icon(Icons.add)),
            MEFab(
              size: MEFabSize.large,
              onPressed: () {},
              icon: const Icon(Icons.create),
            ),
            MEFab.extended(
              size: MEFabSize.small,
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Compose'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SectionLabel('FAB menu'),
        SizedBox(
          height: 320,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 8,
                bottom: 8,
                child: MEFabMenu(
                  items: <MEFabMenuItem>[
                    MEFabMenuItem(
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                      onPressed: () {},
                    ),
                    MEFabMenuItem(
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Gallery'),
                      onPressed: () {},
                    ),
                    MEFabMenuItem(
                      icon: const Icon(Icons.insert_drive_file_outlined),
                      label: const Text('File'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
