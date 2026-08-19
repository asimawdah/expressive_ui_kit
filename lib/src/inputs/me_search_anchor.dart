import 'package:flutter/material.dart';

import '../theme/me_theme.dart';
import 'me_search_bar.dart';

/// Controller for [MESearchAnchor]. Opens and closes the full search view.
class MESearchController extends ChangeNotifier {
  String _text = '';
  bool _isOpen = false;
  VoidCallback? _openView;
  VoidCallback? _closeView;

  String get text => _text;
  bool get isOpen => _isOpen;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    notifyListeners();
  }

  void clear() {
    text = '';
  }

  void openView() => _openView?.call();

  /// Closes the search view. When [selectedText] is set it becomes [text].
  void closeView([String? selectedText]) {
    if (selectedText != null) _text = selectedText;
    _closeView?.call();
    notifyListeners();
  }

  void _bind({
    required VoidCallback openView,
    required VoidCallback closeView,
  }) {
    _openView = openView;
    _closeView = closeView;
  }

  void _setOpen(bool open) {
    if (_isOpen == open) return;
    _isOpen = open;
    notifyListeners();
  }
}

typedef MESearchSuggestionsBuilder = Iterable<Widget> Function(
  BuildContext context,
  MESearchController controller,
);

/// A search bar that opens a full-screen search view with live suggestions.
///
/// Replaces [SearchAnchor] / [SearchAnchor.bar]. The view slides in with a
/// spatial spring; the bar morphs into the view's header.
class MESearchAnchor extends StatefulWidget {
  const MESearchAnchor({
    super.key,
    required this.suggestionsBuilder,
    required this.builder,
    this.searchController,
    this.viewHintText = 'Search',
  })  : barHintText = 'Search',
        leading = null,
        trailing = const <Widget>[];

  /// Convenience constructor that uses an [MESearchBar] as the anchor.
  const MESearchAnchor.bar({
    super.key,
    required this.suggestionsBuilder,
    this.searchController,
    this.barHintText = 'Search',
    this.viewHintText = 'Search',
    this.leading,
    this.trailing = const <Widget>[],
  }) : builder = null;

  final MESearchSuggestionsBuilder suggestionsBuilder;
  final WidgetBuilder? builder;
  final MESearchController? searchController;
  final String barHintText;
  final String viewHintText;
  final Widget? leading;
  final List<Widget> trailing;

  @override
  State<MESearchAnchor> createState() => _MESearchAnchorState();
}

class _MESearchAnchorState extends State<MESearchAnchor> {
  late MESearchController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.searchController == null;
    _controller = widget.searchController ?? MESearchController();
    _controller._bind(openView: _open, closeView: _close);
  }

  @override
  void didUpdateWidget(MESearchAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchController != oldWidget.searchController) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.searchController == null;
      _controller = widget.searchController ?? MESearchController();
      _controller._bind(openView: _open, closeView: _close);
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    _controller._setOpen(true);
    final motion = METheme.of(context).motion;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        transitionDuration: motion.defaultSpatial.approximateDuration,
        reverseTransitionDuration: motion.fastSpatial.approximateDuration,
        pageBuilder: (context, animation, secondary) {
          return _MESearchView(
            controller: _controller,
            suggestionsBuilder: widget.suggestionsBuilder,
            hintText: widget.viewHintText,
          );
        },
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: motion.defaultSpatial.curve,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    _controller._setOpen(false);
  }

  void _close() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return GestureDetector(
        onTap: _open,
        child: widget.builder!(context),
      );
    }
    return MESearchBar(
      hintText: widget.barHintText,
      leading: widget.leading ?? const Icon(Icons.search),
      trailing: widget.trailing,
      onTap: _open,
      readOnly: true,
    );
  }
}

class _MESearchView extends StatefulWidget {
  const _MESearchView({
    required this.controller,
    required this.suggestionsBuilder,
    required this.hintText,
  });

  final MESearchController controller;
  final MESearchSuggestionsBuilder suggestionsBuilder;
  final String hintText;

  @override
  State<_MESearchView> createState() => _MESearchViewState();
}

class _MESearchViewState extends State<_MESearchView> {
  late final TextEditingController _text =
      TextEditingController(text: widget.controller.text);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFromController);
    _text.addListener(_syncToController);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _syncFromController() {
    if (_text.text != widget.controller.text) {
      _text.value = _text.value.copyWith(
        text: widget.controller.text,
        selection: TextSelection.collapsed(
          offset: widget.controller.text.length,
        ),
      );
    }
    setState(() {});
  }

  void _syncToController() {
    widget.controller.text = _text.text;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final suggestions =
        widget.suggestionsBuilder(context, widget.controller).toList();

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: MESearchBar(
                controller: _text,
                hintText: widget.hintText,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => widget.controller.closeView(),
                ),
                trailing: [
                  if (_text.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _text.clear();
                        widget.controller.clear();
                      },
                    ),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) => widget.controller.closeView(value),
              ),
            ),
            Expanded(
              child: suggestions.isEmpty
                  ? Center(
                      child: Text(
                        _text.text.isEmpty
                            ? 'Start typing to search'
                            : 'No matches',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: suggestions,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
