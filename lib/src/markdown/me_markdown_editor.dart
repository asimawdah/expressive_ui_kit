import 'package:flutter/material.dart';

import '../buttons/me_button.dart';
import '../buttons/me_icon_button.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';
import 'me_markdown.dart';

/// A file picked for insertion into the editor via
/// [MEMarkdownEditor.onAttachFile].
class MEMarkdownAttachment {
  const MEMarkdownAttachment({
    required this.name,
    required this.url,
    this.isImage = false,
  });

  /// Display name including extension (e.g. `report.pdf`).
  final String name;

  /// Where the file is hosted / retrievable from.
  final String url;

  /// When true the file is inserted as an image (`![name](url)`) rather
  /// than an attachment card.
  final bool isImage;
}

/// A Material 3 Expressive markdown editor.
///
/// A text area with a formatting toolbar (bold, italic, strikethrough,
/// inline code, heading, quote, list, link, code block) and a spring-
/// animated Write/Preview toggle that renders the content with
/// [MEMarkdown].
///
/// Toolbar actions wrap the current selection (or insert a template at the
/// caret when the selection is empty), matching familiar markdown editor
/// behavior.
class MEMarkdownEditor extends StatefulWidget {
  const MEMarkdownEditor({
    super.key,
    this.controller,
    this.hintText = 'Write markdown...',
    this.minLines = 6,
    this.maxLines = 14,
    this.onChanged,
    this.onAttachFile,
    this.onFileTap,
  });

  /// Controls the markdown source. If omitted the editor owns its own
  /// controller.
  final TextEditingController? controller;
  final String hintText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  /// Called when the attach button is pressed. Return the picked file
  /// (e.g. from a file picker + upload) and the editor inserts
  /// `[file:name](url)` at the caret; return null to cancel. When this is
  /// null the attach button inserts an editable template instead.
  final Future<MEMarkdownAttachment?> Function()? onAttachFile;

  /// Forwarded to [MEMarkdown.onFileTap] in preview mode.
  final ValueChanged<String>? onFileTap;

  @override
  State<MEMarkdownEditor> createState() => _MEMarkdownEditorState();
}

class _MEMarkdownEditorState extends State<MEMarkdownEditor>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _preview = false;
  late final AnimationController _toggle =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(MEMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _toggle.dispose();
    super.dispose();
  }

  void _setPreview(bool preview) {
    if (_preview == preview) return;
    setState(() => _preview = preview);
    springTo(_toggle, preview ? 1 : 0,
        METheme.of(context).motion.defaultSpatial);
  }

  /// Wraps the current selection with [prefix]/[suffix], or inserts
  /// `prefix + placeholder + suffix` at the caret when nothing is selected.
  void _wrapSelection(String prefix, String suffix, String placeholder) {
    final value = _controller.value;
    final selection = value.selection;
    final text = value.text;

    if (!selection.isValid) {
      final insert = '$prefix$placeholder$suffix';
      _controller.value = TextEditingValue(
        text: text + insert,
        selection: TextSelection(
          baseOffset: text.length + prefix.length,
          extentOffset: text.length + prefix.length + placeholder.length,
        ),
      );
    } else if (selection.isCollapsed) {
      final insert = '$prefix$placeholder$suffix';
      final newText = text.replaceRange(selection.start, selection.start, insert);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.start + prefix.length + placeholder.length,
        ),
      );
    } else {
      final selected = selection.textInside(text);
      final newText =
          text.replaceRange(selection.start, selection.end, '$prefix$selected$suffix');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.end + prefix.length + suffix.length,
        ),
      );
    }
    widget.onChanged?.call(_controller.text);
  }

  /// Inserts [snippet] as a standalone block on its own line at the caret.
  void _insertBlock(String snippet) {
    final value = _controller.value;
    final text = value.text;
    final offset =
        value.selection.isValid ? value.selection.end : text.length;
    final needsLeadingBreak = offset > 0 && text[offset - 1] != '\n';
    final insert = '${needsLeadingBreak ? '\n' : ''}$snippet\n';
    final newText = text.replaceRange(offset, offset, insert);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + insert.length),
    );
    widget.onChanged?.call(_controller.text);
  }

  Future<void> _attach() async {
    if (widget.onAttachFile == null) {
      _insertBlock('[file:document.pdf](https://)');
      return;
    }
    final attachment = await widget.onAttachFile!();
    if (attachment == null || !mounted) return;
    _insertBlock(attachment.isImage
        ? '![${attachment.name}](${attachment.url})'
        : '[file:${attachment.name}](${attachment.url})');
  }

  /// Prepends [linePrefix] to the line containing the caret.
  void _prefixLine(String linePrefix) {
    final value = _controller.value;
    final text = value.text;
    final offset =
        value.selection.isValid ? value.selection.baseOffset : text.length;
    final lineStart = text.lastIndexOf('\n', (offset - 1).clamp(0, text.length)) + 1;
    final newText = text.replaceRange(lineStart, lineStart, linePrefix);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + linePrefix.length),
    );
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ToolbarButton(
                          icon: Icons.format_bold,
                          tooltip: 'Bold',
                          enabled: !_preview,
                          onPressed: () => _wrapSelection('**', '**', 'bold'),
                        ),
                        _ToolbarButton(
                          icon: Icons.format_italic,
                          tooltip: 'Italic',
                          enabled: !_preview,
                          onPressed: () => _wrapSelection('*', '*', 'italic'),
                        ),
                        _ToolbarButton(
                          icon: Icons.format_strikethrough,
                          tooltip: 'Strikethrough',
                          enabled: !_preview,
                          onPressed: () => _wrapSelection('~~', '~~', 'text'),
                        ),
                        _ToolbarButton(
                          icon: Icons.code,
                          tooltip: 'Inline code',
                          enabled: !_preview,
                          onPressed: () => _wrapSelection('`', '`', 'code'),
                        ),
                        _ToolbarButton(
                          icon: Icons.title,
                          tooltip: 'Heading',
                          enabled: !_preview,
                          onPressed: () => _prefixLine('## '),
                        ),
                        _ToolbarButton(
                          icon: Icons.format_quote,
                          tooltip: 'Quote',
                          enabled: !_preview,
                          onPressed: () => _prefixLine('> '),
                        ),
                        _ToolbarButton(
                          icon: Icons.format_list_bulleted,
                          tooltip: 'List',
                          enabled: !_preview,
                          onPressed: () => _prefixLine('- '),
                        ),
                        _ToolbarButton(
                          icon: Icons.link,
                          tooltip: 'Link',
                          enabled: !_preview,
                          onPressed: () =>
                              _wrapSelection('[', '](https://)', 'label'),
                        ),
                        _ToolbarButton(
                          icon: Icons.data_object,
                          tooltip: 'Code block',
                          enabled: !_preview,
                          onPressed: () =>
                              _wrapSelection('\n```\n', '\n```\n', 'code'),
                        ),
                        _ToolbarButton(
                          icon: Icons.image_outlined,
                          tooltip: 'Image',
                          enabled: !_preview,
                          onPressed: () =>
                              _insertBlock('![alt text](https://)'),
                        ),
                        _ToolbarButton(
                          icon: Icons.attach_file,
                          tooltip: 'Attach file',
                          enabled: !_preview,
                          onPressed: _attach,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _WritePreviewToggle(
                  preview: _preview,
                  toggle: _toggle,
                  onChanged: _setPreview,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _preview
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: widget.minLines * 24.0,
                    ),
                    child: _controller.text.trim().isEmpty
                        ? Text(
                            'Nothing to preview',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: scheme.onSurfaceVariant),
                          )
                        : MEMarkdown(
                            data: _controller.text,
                            onFileTap: widget.onFileTap,
                          ),
                  )
                : TextField(
                    controller: _controller,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    onChanged: widget.onChanged,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'monospace',
                          height: 1.6,
                        ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MEIconButton(
        icon: Icon(icon, size: 20),
        variant: MEButtonVariant.text,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

/// A two-segment Write/Preview toggle with a spring-sliding pill.
class _WritePreviewToggle extends StatelessWidget {
  const _WritePreviewToggle({
    required this.preview,
    required this.toggle,
    required this.onChanged,
  });

  final bool preview;
  final AnimationController toggle;
  final ValueChanged<bool> onChanged;

  static const double _segmentWidth = 44;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 36,
      width: _segmentWidth * 2 + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: AnimatedBuilder(
        animation: toggle,
        builder: (context, _) {
          final t = toggle.value.clamp(-0.2, 1.2);
          return Stack(
            children: [
              Positioned(
                left: t * _segmentWidth,
                top: 0,
                bottom: 0,
                width: _segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              Row(
                children: [
                  _segment(context, Icons.edit_outlined, 'Write', false),
                  _segment(context, Icons.visibility_outlined, 'Preview', true),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _segment(
      BuildContext context, IconData icon, String label, bool isPreview) {
    final scheme = Theme.of(context).colorScheme;
    final active = preview == isPreview;
    return SizedBox(
      width: _segmentWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(isPreview),
        child: Semantics(
          button: true,
          selected: active,
          label: label,
          child: Icon(
            icon,
            size: 18,
            color: active ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
