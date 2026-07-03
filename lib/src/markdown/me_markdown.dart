import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../communication/me_divider.dart';
import '../containers/me_file_card.dart';
import '../containers/me_image.dart';
import '../theme/me_shapes.dart';
import 'me_syntax_highlight.dart';

/// A Material 3 Expressive markdown viewer.
///
/// Renders a useful subset of markdown with zero dependencies, styled with
/// M3E shape and color tokens:
///
/// * Headings `#` through `######` (emphasized weight)
/// * Bold `**text**`, italic `*text*`, strikethrough `~~text~~`
/// * Inline code `` `code` `` and fenced code blocks ` ``` ` with
///   syntax highlighting (via [MECodeView]) and a copy button
/// * Links `[label](url)` via [onLinkTap]
/// * Images `![alt](url)` rendered with [MEImage]
/// * File attachments `[file:name.ext](url)` rendered with [MEFileCard]
///   via [onFileTap]
/// * Unordered `-` / `*` and ordered `1.` lists (with nesting by indent)
/// * Blockquotes `>` with an expressive accent bar
/// * Horizontal rules `---`
class MEMarkdown extends StatelessWidget {
  const MEMarkdown({
    super.key,
    required this.data,
    this.onLinkTap,
    this.onFileTap,
    this.selectable = false,
    this.showCodeCopyButton = true,
  });

  /// The markdown source text.
  final String data;

  /// Called with the URL when a `[label](url)` link is tapped.
  final ValueChanged<String>? onLinkTap;

  /// Called with the URL when a `[file:name.ext](url)` attachment card is
  /// tapped. Falls back to [onLinkTap] when null.
  final ValueChanged<String>? onFileTap;

  /// Whether paragraph text is selectable.
  final bool selectable;

  /// Whether fenced code blocks show a copy-to-clipboard button.
  final bool showCodeCopyButton;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(data);
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) children.add(SizedBox(height: blocks[i].topSpacing));
      children.add(_buildBlock(context, blocks[i]));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildBlock(BuildContext context, _MdBlock block) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    switch (block.type) {
      case _MdBlockType.heading:
        final styles = [
          text.headlineMedium,
          text.headlineSmall,
          text.titleLarge,
          text.titleMedium,
          text.titleSmall,
          text.labelLarge,
        ];
        final base = styles[(block.level - 1).clamp(0, 5)] ?? text.titleMedium!;
        return _inlineText(
          context,
          block.text,
          base.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        );

      case _MdBlockType.paragraph:
        return _inlineText(context, block.text,
            text.bodyMedium!.copyWith(height: 1.5));

      case _MdBlockType.codeBlock:
        return MECodeView(
          code: block.text,
          language: block.language,
          showCopyButton: showCodeCopyButton,
        );

      case _MdBlockType.image:
        return MEImage(
          url: block.url ?? '',
          aspectRatio: 16 / 9,
          semanticLabel: block.text.isEmpty ? null : block.text,
        );

      case _MdBlockType.file:
        return Align(
          alignment: Alignment.centerLeft,
          child: MEFileCard(
            name: block.text,
            dense: true,
            onPressed: (onFileTap ?? onLinkTap) == null
                ? null
                : () => (onFileTap ?? onLinkTap)!(block.url ?? ''),
          ),
        );

      case _MdBlockType.quote:
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: scheme.primary, width: 4),
            ),
            color: scheme.surfaceContainerLow,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(MECorners.medium),
              bottomRight: Radius.circular(MECorners.medium),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _inlineText(
              context,
              block.text,
              text.bodyMedium!.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        );

      case _MdBlockType.listItem:
        final marker = block.ordered
            ? Text(
                '${block.ordinal}.',
                style: text.bodyMedium!.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
        return Padding(
          padding: EdgeInsets.only(left: 4.0 + block.indent * 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20, child: marker),
              const SizedBox(width: 4),
              Expanded(
                child: _inlineText(context, block.text,
                    text.bodyMedium!.copyWith(height: 1.5)),
              ),
            ],
          ),
        );

      case _MdBlockType.rule:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: MEDivider(),
        );
    }
  }

  Widget _inlineText(BuildContext context, String source, TextStyle style) {
    final span = _parseInline(context, source, style);
    if (selectable) return SelectableText.rich(span);
    return Text.rich(span);
  }

  /// Parses inline markdown (`**`, `*`, `~~`, `` ` ``, links) into spans.
  TextSpan _parseInline(
      BuildContext context, String source, TextStyle style) {
    final scheme = Theme.of(context).colorScheme;
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*(?<bold>.+?)\*\*)'
      r'|(\*(?<italic>.+?)\*)'
      r'|(~~(?<strike>.+?)~~)'
      r'|(`(?<code>.+?)`)'
      r'|(\[(?<label>[^\]]+)\]\((?<url>[^)]+)\))',
    );

    var cursor = 0;
    for (final match in pattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      if (match.namedGroup('bold') != null) {
        spans.add(TextSpan(
          text: match.namedGroup('bold'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else if (match.namedGroup('italic') != null) {
        spans.add(TextSpan(
          text: match.namedGroup('italic'),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.namedGroup('strike') != null) {
        spans.add(TextSpan(
          text: match.namedGroup('strike'),
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ));
      } else if (match.namedGroup('code') != null) {
        spans.add(TextSpan(
          text: ' ${match.namedGroup('code')} ',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: (style.fontSize ?? 14) * 0.9,
            backgroundColor: scheme.surfaceContainerHigh,
            color: scheme.onSurface,
          ),
        ));
      } else if (match.namedGroup('label') != null) {
        final url = match.namedGroup('url')!;
        spans.add(TextSpan(
          text: match.namedGroup('label'),
          style: TextStyle(
            color: scheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: scheme.primary,
          ),
          recognizer: onLinkTap == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onLinkTap!(url)),
        ));
      }
      cursor = match.end;
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }
    return TextSpan(style: style, children: spans);
  }

  static List<_MdBlock> _parseBlocks(String source) {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final blocks = <_MdBlock>[];
    var i = 0;
    var ordinal = 0;

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trimLeft();

      if (trimmed.isEmpty) {
        ordinal = 0;
        i++;
        continue;
      }

      // Fenced code block.
      if (trimmed.startsWith('```')) {
        final language = trimmed.substring(3).trim();
        final buffer = <String>[];
        i++;
        while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
          buffer.add(lines[i]);
          i++;
        }
        i++; // Skip closing fence.
        blocks.add(_MdBlock(
          type: _MdBlockType.codeBlock,
          text: buffer.join('\n'),
          language: language,
        ));
        continue;
      }

      // Horizontal rule.
      if (RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(trimmed)) {
        blocks.add(const _MdBlock(type: _MdBlockType.rule, text: ''));
        i++;
        continue;
      }

      // Image on its own line: ![alt](url)
      final image =
          RegExp(r'^!\[([^\]]*)\]\(([^)]+)\)$').firstMatch(trimmed);
      if (image != null) {
        blocks.add(_MdBlock(
          type: _MdBlockType.image,
          text: image.group(1)!,
          url: image.group(2),
        ));
        i++;
        continue;
      }

      // File attachment on its own line: [file:name.ext](url)
      final file =
          RegExp(r'^\[file:([^\]]+)\]\(([^)]+)\)$').firstMatch(trimmed);
      if (file != null) {
        blocks.add(_MdBlock(
          type: _MdBlockType.file,
          text: file.group(1)!.trim(),
          url: file.group(2),
        ));
        i++;
        continue;
      }

      // Heading.
      final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
      if (heading != null) {
        blocks.add(_MdBlock(
          type: _MdBlockType.heading,
          text: heading.group(2)!,
          level: heading.group(1)!.length,
        ));
        i++;
        continue;
      }

      // Blockquote (merge consecutive quote lines).
      if (trimmed.startsWith('> ') || trimmed == '>') {
        final buffer = <String>[];
        while (i < lines.length &&
            (lines[i].trimLeft().startsWith('> ') ||
                lines[i].trimLeft() == '>')) {
          final l = lines[i].trimLeft();
          buffer.add(l.length > 2 ? l.substring(2) : '');
          i++;
        }
        blocks.add(_MdBlock(
          type: _MdBlockType.quote,
          text: buffer.join('\n'),
        ));
        continue;
      }

      // List item (unordered or ordered), with nesting by indentation.
      final indent = (line.length - trimmed.length) ~/ 2;
      final unordered = RegExp(r'^[-*]\s+(.*)$').firstMatch(trimmed);
      if (unordered != null) {
        blocks.add(_MdBlock(
          type: _MdBlockType.listItem,
          text: unordered.group(1)!,
          indent: indent,
        ));
        i++;
        continue;
      }
      final orderedMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (orderedMatch != null) {
        ordinal++;
        blocks.add(_MdBlock(
          type: _MdBlockType.listItem,
          text: orderedMatch.group(2)!,
          indent: indent,
          ordered: true,
          ordinal: ordinal,
        ));
        i++;
        continue;
      }

      // Paragraph (merge consecutive plain lines).
      final buffer = <String>[trimmed];
      i++;
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !_isBlockStart(lines[i].trimLeft())) {
        buffer.add(lines[i].trim());
        i++;
      }
      blocks.add(_MdBlock(
        type: _MdBlockType.paragraph,
        text: buffer.join(' '),
      ));
    }

    return blocks;
  }

  static bool _isBlockStart(String trimmed) {
    return trimmed.startsWith('#') ||
        trimmed.startsWith('```') ||
        trimmed.startsWith('> ') ||
        RegExp(r'^[-*]\s').hasMatch(trimmed) ||
        RegExp(r'^\d+\.\s').hasMatch(trimmed) ||
        RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(trimmed) ||
        RegExp(r'^!\[[^\]]*\]\([^)]+\)$').hasMatch(trimmed) ||
        RegExp(r'^\[file:[^\]]+\]\([^)]+\)$').hasMatch(trimmed);
  }
}

enum _MdBlockType {
  heading,
  paragraph,
  codeBlock,
  quote,
  listItem,
  rule,
  image,
  file,
}

class _MdBlock {
  const _MdBlock({
    required this.type,
    required this.text,
    this.level = 1,
    this.language,
    this.url,
    this.indent = 0,
    this.ordered = false,
    this.ordinal = 0,
  });

  final _MdBlockType type;
  final String text;
  final int level;
  final String? language;
  final String? url;
  final int indent;
  final bool ordered;
  final int ordinal;

  double get topSpacing {
    switch (type) {
      case _MdBlockType.heading:
        return 20;
      case _MdBlockType.listItem:
        return 6;
      case _MdBlockType.rule:
        return 12;
      default:
        return 12;
    }
  }
}
