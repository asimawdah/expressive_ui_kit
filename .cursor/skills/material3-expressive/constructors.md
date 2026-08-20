# Verified constructors (copy these)

Read the source file if a parameter is missing here. Do not invent names.
All of these are exported from `package:material3_expressive/material3_expressive.dart`.

## Theme

```dart
METheme(
  data: METhemeData.expressive, // or METhemeData.standard
  child: child,
);
```

## Buttons

```dart
MEButton.filled( // also .tonal .elevated .outlined .text
  size: MEButtonSize.small, // extraSmall small medium large extraLarge
  shape: MEButtonShape.round, // or .square
  icon: const Icon(Icons.send),
  onPressed: () {},
  child: const Text('Send'),
);

METoggleButton.filled( // also .tonal .outlined .text
  checked: favorite,
  icon: const Icon(Icons.favorite_border),
  checkedIcon: const Icon(Icons.favorite),
  label: const Text('Favorite'),
  onCheckedChange: (v) => setState(() => favorite = v),
);

MEIconButton(
  icon: const Icon(Icons.settings_outlined),
  selectedIcon: const Icon(Icons.settings),
  selected: selected, // null = not a toggle
  variant: MEButtonVariant.tonal,
  size: MEButtonSize.small,
  width: MEIconButtonWidth.normal, // narrow normal wide
  onPressed: () {},
);

MEFab(
  icon: const Icon(Icons.add),
  size: MEFabSize.medium, // small medium large
  variant: MEFabVariant.primary, // secondary tertiary tonal
  onPressed: () {},
);

MEFab.extended(
  icon: const Icon(Icons.edit),
  label: const Text('Compose'),
  onPressed: () {},
);

MESplitButton(
  icon: const Icon(Icons.check),
  onPressed: () {},
  menu: const [
    MEMenuEntry(label: 'Save as draft', value: 'draft'),
    MEMenuEntry(label: 'Save a copy', value: 'copy'),
  ],
  onSelected: (value) {},
  child: const Text('Save'),
);
```

## App bar (sliver — not Scaffold.appBar)

```dart
CustomScrollView(
  slivers: [
    MEAppBar(
      title: const Text('Inbox'),
      subtitle: const Text('Supporting text'),
      size: MEAppBarSize.medium, // small medium large
      pinned: true,
      actions: [
        MEIconButton(icon: const Icon(Icons.search), onPressed: () {}),
      ],
    ),
    MESliverList(
      itemCount: items.length,
      itemBuilder: (context, i) => MEListTile(title: Text(items[i])),
    ),
  ],
);
```

## Navigation

```dart
MENavigationBar(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: const [
    MENavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    MENavigationDestination(icon: Icon(Icons.search), label: 'Search'),
  ],
);

MEDrawer(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: const [
    MEDrawerDestination(icon: Icons.inbox_outlined, label: 'Inbox'), // IconData, not Widget
  ],
);

MEBottomAppBar(
  actions: [
    MEIconButton(icon: const Icon(Icons.archive_outlined), onPressed: () {}),
  ],
  fab: MEFab(size: MEFabSize.small, icon: const Icon(Icons.add), onPressed: () {}),
);
```

## Menu

```dart
MEMenu(
  anchorBuilder: (context, open) => MEButton.outlined(
    icon: const Icon(Icons.arrow_drop_down),
    onPressed: open,
    child: const Text('Open menu'),
  ),
  children: const [
    MEMenuEntry(label: 'Edit', value: 'edit'),
    MEMenuDivider(),
    MEMenuEntry(label: 'Delete', value: 'delete', isDestructive: true),
  ],
  onSelected: (value) {},
);
```

## Search

```dart
MESearchAnchor.bar(
  barHintText: 'Search',
  suggestionsBuilder: (context, controller) => [
    MEListTile(
      title: Text('Result for ${controller.text}'),
      onPressed: () => controller.closeView('Result'),
    ),
  ],
);
```

## Dialogs / toasts

```dart
showMEDialog(
  context: context,
  builder: (context) => MEDialog(
    icon: const Icon(Icons.info_outline),
    title: const Text('Title'),
    content: const Text('Body'),
    actions: [
      MEButton.text(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      MEButton.filled(onPressed: () => Navigator.pop(context), child: const Text('OK')),
    ],
  ),
);

showMEToast(context: context, message: 'Saved');
showMESnackBar(context: context, message: 'Deleted', actionLabel: 'Undo', onAction: () {});
```

## Inputs / lists

```dart
METextField(
  label: 'Email',
  hintText: 'you@example.com',
  variant: METextFieldVariant.filled, // or .outlined
  onChanged: (v) {},
);

MEListGroup(
  children: [
    MEListTile(title: const Text('Notifications'), onPressed: () {}),
    MEListTile(title: const Text('Privacy'), onPressed: () {}),
  ],
);
```

## Controls

```dart
MESwitch(value: on, onChanged: (v) => setState(() => on = v));
MECheckbox(value: checked, label: const Text('Agree'), onChanged: (v) {});
MECheckbox(
  tristate: true,
  value: mixed,
  onChanged: (v) => setState(() => mixed = v),
);
MESlider(value: value, onChanged: (v) => setState(() => value = v));
MESlider.wavy(value: value, onChanged: (v) {});
MESlider.vertical(value: value, onChanged: (v) {});
```
