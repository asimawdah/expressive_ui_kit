import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive chat message composer.
///
/// A pill-shaped input row with an optional leading action (e.g. attach),
/// and a send button that springs in — scaling up with a bounce — as soon
/// as the field contains text, echoing the FAB's expressive entrance.
class MEChatInput extends StatefulWidget {
  const MEChatInput({
    super.key,
    this.controller,
    this.hintText = 'Message',
    this.onSend,
    this.leading,
    this.enabled = true,
  });

  /// Controls the composer text. If omitted the widget owns its own
  /// controller.
  final TextEditingController? controller;
  final String hintText;

  /// Called with the trimmed text when the send button is pressed or the
  /// keyboard action submits. The field clears afterwards.
  final ValueChanged<String>? onSend;

  /// Optional leading widget (e.g. an attach icon button).
  final Widget? leading;
  final bool enabled;

  @override
  State<MEChatInput> createState() => _MEChatInputState();
}

class _MEChatInputState extends State<MEChatInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _ownsController = false;
  late final AnimationController _sendAnim =
      AnimationController.unbounded(vsync: this, value: 0);
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _hasText = _controller.text.trim().isNotEmpty;
    if (_hasText) _sendAnim.value = 1;
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(MEChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextChange);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
      _controller.addListener(_handleTextChange);
    }
  }

  void _handleTextChange() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      springTo(
        _sendAnim,
        hasText ? 1 : 0,
        hasText
            ? METheme.of(context).motion.fastSpatial
            : METheme.of(context).motion.defaultEffects,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    _sendAnim.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.leading != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: widget.leading,
                  )
                else
                  const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        // Send button springs in when there is text.
        AnimatedBuilder(
          animation: _sendAnim,
          builder: (context, child) {
            final t = _sendAnim.value;
            final scale = t.clamp(0.0, 1.2);
            final width = (60.0 * t).clamp(0.0, 72.0);
            return SizedBox(
              width: width,
              child: scale <= 0.01
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Transform.scale(scale: scale, child: child),
                    ),
            );
          },
          child: SizedBox(
            width: 52,
            height: 52,
            child: Material(
              color: scheme.primary,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.enabled ? _send : null,
                child: Semantics(
                  button: true,
                  label: 'Send message',
                  child: Icon(Icons.arrow_upward, color: scheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
