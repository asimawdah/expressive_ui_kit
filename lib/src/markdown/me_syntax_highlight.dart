import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A lightweight, zero-dependency syntax highlighter used by [MEMarkdown]
/// code blocks (and usable standalone via [MECodeView]).
///
/// It tokenizes source into comments, strings, keywords, types, numbers,
/// functions and punctuation, and colors them with scheme-derived hues so
/// highlighting adapts to light/dark and dynamic color themes.
class MESyntaxTheme {
  const MESyntaxTheme({
    required this.keyword,
    required this.type,
    required this.string,
    required this.comment,
    required this.number,
    required this.function,
    required this.constant,
    required this.punctuation,
    required this.plain,
  });

  final Color keyword;
  final Color type;
  final Color string;
  final Color comment;
  final Color number;
  final Color function;
  final Color constant;
  final Color punctuation;
  final Color plain;

  /// Derives a syntax palette from the ambient [ColorScheme] so code
  /// blocks feel native to the app theme.
  factory MESyntaxTheme.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool dark = scheme.brightness == Brightness.dark;
    return MESyntaxTheme(
      keyword: scheme.primary,
      type: scheme.tertiary,
      string: dark ? const Color(0xFF8FCE9C) : const Color(0xFF2E7D46),
      comment: scheme.onSurfaceVariant.withValues(alpha: 0.65),
      number: dark ? const Color(0xFFE0B48A) : const Color(0xFF9A5B1F),
      function: scheme.secondary,
      constant: scheme.tertiary,
      punctuation: scheme.onSurfaceVariant,
      plain: scheme.onSurface,
    );
  }
}

/// Token categories produced by [highlightSyntax].
enum MESyntaxToken {
  keyword,
  type,
  string,
  comment,
  number,
  function,
  constant,
  punctuation,
  plain,
}

const Set<String> _keywords = {
  // Shared across dart/js/ts/python/kotlin/swift/java...
  'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
  'class', 'const', 'continue', 'def', 'default', 'defer', 'del', 'do',
  'dynamic', 'elif', 'else', 'enum', 'except', 'export', 'extends',
  'extension', 'external', 'factory', 'final', 'finally', 'fn', 'for',
  'from', 'fun', 'func', 'function', 'get', 'global', 'goto', 'if',
  'implements', 'import', 'in', 'inline', 'interface', 'internal', 'is',
  'lambda', 'late', 'let', 'library', 'match', 'mixin', 'mut', 'namespace',
  'new', 'nonlocal', 'not', 'of', 'on', 'operator', 'or', 'override',
  'package', 'part', 'pass', 'private', 'protected', 'public', 'pub',
  'raise', 'required', 'return', 'sealed', 'set', 'show', 'static',
  'struct', 'super', 'switch', 'sync', 'this', 'throw', 'trait', 'try',
  'type', 'typedef', 'typeof', 'use', 'var', 'virtual', 'void', 'when',
  'where', 'while', 'with', 'yield', 'and', 'elsif', 'end', 'select',
  'insert', 'update', 'delete', 'create', 'table', 'into', 'values',
  'echo', 'then', 'fi', 'esac', 'done', 'local',
};

const Set<String> _constants = {
  'true',
  'false',
  'null',
  'nil',
  'none',
  'undefined',
  'self',
  'True',
  'False',
  'None',
  'NaN',
  'Infinity',
};

final RegExp _tokenPattern = RegExp(
  // Comments: //... , #... , /* ... */ (multiline handled per-line), <!-- -->
  r'(?<comment>//[^\n]*|#[^\n]*|/\*.*?\*/|<!--.*?-->)'
  // Strings: single, double, triple, backtick, with escapes.
  r"|(?<string>'''[\s\S]*?'''|"
  '"""[\\s\\S]*?"""'
  r"|'(?:\\.|[^'\\])*'|"
  '"(?:\\\\.|[^"\\\\])*"'
  r'|`(?:\\.|[^`\\])*`)'
  // Numbers: hex, decimal, scientific, with optional suffix.
  r'|(?<number>\b0[xX][0-9a-fA-F_]+\b|\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b)'
  // Annotations / decorators: @something
  r'|(?<annotation>@[A-Za-z_][\w]*)'
  // Identifiers (classified as keyword/type/function/constant/plain later).
  r'|(?<ident>[A-Za-z_$][\w$]*)'
  // Punctuation and operators.
  r'|(?<punct>[{}()\[\];,.:<>=+\-*/%!&|^~?]+)',
  dotAll: true,
);

/// Tokenizes [source] and returns styled spans using [theme].
///
/// The [language] hint is accepted for future specialization but the
/// tokenizer is language-agnostic and handles C-like, Python-like, and
/// shell-like sources well in practice.
List<InlineSpan> highlightSyntax(
  String source,
  MESyntaxTheme theme, {
  String? language,
  TextStyle? baseStyle,
}) {
  final spans = <InlineSpan>[];
  var cursor = 0;

  TextStyle styleFor(MESyntaxToken token) {
    switch (token) {
      case MESyntaxToken.keyword:
        return TextStyle(color: theme.keyword, fontWeight: FontWeight.w600);
      case MESyntaxToken.type:
        return TextStyle(color: theme.type);
      case MESyntaxToken.string:
        return TextStyle(color: theme.string);
      case MESyntaxToken.comment:
        return TextStyle(color: theme.comment, fontStyle: FontStyle.italic);
      case MESyntaxToken.number:
        return TextStyle(color: theme.number);
      case MESyntaxToken.function:
        return TextStyle(color: theme.function);
      case MESyntaxToken.constant:
        return TextStyle(color: theme.constant, fontWeight: FontWeight.w500);
      case MESyntaxToken.punctuation:
        return TextStyle(color: theme.punctuation);
      case MESyntaxToken.plain:
        return TextStyle(color: theme.plain);
    }
  }

  void add(String text, MESyntaxToken token) {
    if (text.isEmpty) return;
    spans.add(TextSpan(text: text, style: styleFor(token)));
  }

  for (final match in _tokenPattern.allMatches(source)) {
    if (match.start > cursor) {
      add(source.substring(cursor, match.start), MESyntaxToken.plain);
    }

    if (match.namedGroup('comment') != null) {
      add(match.group(0)!, MESyntaxToken.comment);
    } else if (match.namedGroup('string') != null) {
      add(match.group(0)!, MESyntaxToken.string);
    } else if (match.namedGroup('number') != null) {
      add(match.group(0)!, MESyntaxToken.number);
    } else if (match.namedGroup('annotation') != null) {
      add(match.group(0)!, MESyntaxToken.function);
    } else if (match.namedGroup('ident') != null) {
      final ident = match.group(0)!;
      if (_keywords.contains(ident)) {
        add(ident, MESyntaxToken.keyword);
      } else if (_constants.contains(ident)) {
        add(ident, MESyntaxToken.constant);
      } else if (RegExp(r'^[A-Z]').hasMatch(ident)) {
        // PascalCase identifiers read as types/classes.
        add(ident, MESyntaxToken.type);
      } else if (match.end < source.length && source[match.end] == '(') {
        add(ident, MESyntaxToken.function);
      } else {
        add(ident, MESyntaxToken.plain);
      }
    } else if (match.namedGroup('punct') != null) {
      add(match.group(0)!, MESyntaxToken.punctuation);
    }
    cursor = match.end;
  }
  if (cursor < source.length) {
    add(source.substring(cursor), MESyntaxToken.plain);
  }

  if (baseStyle != null) {
    return [TextSpan(style: baseStyle, children: spans)];
  }
  return spans;
}

/// A standalone syntax-highlighted, selectable code view with an M3E
/// container, language chip, and copy button. [MEMarkdown] uses this for
/// fenced code blocks; it also works on its own.
class MECodeView extends StatelessWidget {
  const MECodeView({
    super.key,
    required this.code,
    this.language,
    this.showCopyButton = true,
  });

  final String code;
  final String? language;
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final syntax = MESyntaxTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                if (language != null && language!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      language!,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (showCopyButton) _CopyButton(code: code),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SelectableText.rich(
              TextSpan(
                style: theme.textTheme.bodySmall!.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
                children: highlightSyntax(code, syntax, language: language),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Copy-to-clipboard button that morphs into a check mark on success.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});

  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: _copied ? 'Copied' : 'Copy code',
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          _copied ? Icons.check : Icons.copy_outlined,
          key: ValueKey(_copied),
          size: 18,
          color: _copied ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
