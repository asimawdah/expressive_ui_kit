# Verified constructors (copy these)

Read the source file if a parameter is missing here. Do not invent names.
All of these are exported from `package:material3_expressive/material3_expressive.dart`.

## Theme

```dart
METheme(
  data: METhemeData.expressive, // or METhemeData.standard
  child: child,
);

final motion = METheme.of(context).motion;
springTo(controller, 1, motion.defaultSpatial); // motor MaterialSpringMotion
springTo(controller, 1, motion.popup); // menus / dropdowns
springTo(controller, 1, motion.overflow); // overflow extra-actions
MEMotionBuilder(
  value: pressed ? 1 : 0,
  spec: motion.defaultSpatial,
  builder: (context, t, child) => child!,
);
MEMotionReveal(visible: open, spec: motion.defaultSpatial, child: child);
MEMotionWidth(width: expanded ? 220 : 96, spec: motion.defaultSpatial, child: child);
MEMotionOpacity(opacity: shown ? 1 : 0, spec: motion.defaultEffects, child: child);
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

METoggleButtonGroup(
  selected: const {0},
  onChanged: (next) {},
  style: MEButtonGroupStyle.standard, // or .connected
  items: const [
    METoggleButtonGroupItem(icon: Icon(Icons.format_bold), tooltip: 'Bold'),
    METoggleButtonGroupItem(icon: Icon(Icons.format_italic), tooltip: 'Italic'),
  ],
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

## App bar

```dart
// Scaffold.appBar — 64dp, not a sliver.
Scaffold(
  appBar: METopAppBar(
    title: const Text('Inbox'),
    subtitle: const Text('3 unread'),
  ),
);

// Collapsing / medium / large — sliver only.
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
    MEDrawerDestination(
      icon: Icons.send_outlined,
      label: 'Sent',
      sectionLabel: 'Mail',
    ),
  ],
);

MENavigationRail(
  expanded: true,
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  fab: MEFab(size: MEFabSize.small, icon: const Icon(Icons.add), onPressed: () {}),
  destinations: const [
    MENavigationDestination(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
      sectionLabel: 'Mail',
    ),
    MENavigationDestination(icon: Icon(Icons.search), label: 'Search'),
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
MESlider(
  value: value,
  thumbLength: 50,
  cornerRadius: 8,
  onChanged: (v) {},
);

MEDropdown<String>(
  value: selected,
  hintText: 'Choose',
  searchEnabled: true,
  items: const [
    MEMenuItem(value: 'a', label: 'Alpha'),
  ],
  onChanged: (v) {},
);

MECarousel(
  type: MECarouselType.hero, // contained / uncontained
  onChange: (index) {},
  children: const [ColoredBox(color: Colors.teal)],
);

MEListTile(
  variant: MEListTileVariant.outlined,
  title: const Text('Wireless charging'),
  onPressed: () {},
);

METabBar(
  variant: METabBarVariant.primary, // or .secondary
  selectedIndex: tab,
  onSelected: (i) {},
  tabs: const [METab(label: 'Day'), METab(label: 'Week')],
);
```
