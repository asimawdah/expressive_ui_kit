import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// A Material 3 Expressive file attachment card.
///
/// Shows a type-tinted icon derived from the file extension, the file
/// name, and optional metadata (size, subtitle). Built on [MEPressable],
/// so it press-morphs and squashes like every other ME surface.
///
/// Used by [MEMarkdown] to render `[file:name.ext](url)` attachments and
/// by [MEChatBubble]-style UIs for message attachments; also works
/// standalone in lists of downloads or uploads.
class MEFileCard extends StatelessWidget {
  const MEFileCard({
    super.key,
    required this.name,
    this.size,
    this.onPressed,
    this.trailing,
    this.dense = false,
  });

  /// File name including extension (e.g. `report.pdf`).
  final String name;

  /// Optional human-readable size or subtitle (e.g. `2.4 MB`).
  final String? size;

  /// Called when the card is tapped (e.g. open or download the file).
  final VoidCallback? onPressed;

  /// Optional trailing widget (e.g. a download icon button).
  final Widget? trailing;

  /// Compact layout for inline/markdown use.
  final bool dense;

  static const Map<String, IconData> _icons = {
    'pdf': Icons.picture_as_pdf_outlined,
    'doc': Icons.description_outlined,
    'docx': Icons.description_outlined,
    'txt': Icons.notes_outlined,
    'md': Icons.notes_outlined,
    'xls': Icons.table_chart_outlined,
    'xlsx': Icons.table_chart_outlined,
    'csv': Icons.table_chart_outlined,
    'ppt': Icons.slideshow_outlined,
    'pptx': Icons.slideshow_outlined,
    'zip': Icons.folder_zip_outlined,
    'rar': Icons.folder_zip_outlined,
    'gz': Icons.folder_zip_outlined,
    'png': Icons.image_outlined,
    'jpg': Icons.image_outlined,
    'jpeg': Icons.image_outlined,
    'gif': Icons.gif_box_outlined,
    'svg': Icons.image_outlined,
    'webp': Icons.image_outlined,
    'mp3': Icons.audio_file_outlined,
    'wav': Icons.audio_file_outlined,
    'mp4': Icons.video_file_outlined,
    'mov': Icons.video_file_outlined,
    'webm': Icons.video_file_outlined,
    'dart': Icons.code_outlined,
    'js': Icons.code_outlined,
    'ts': Icons.code_outlined,
    'py': Icons.code_outlined,
    'json': Icons.data_object_outlined,
    'yaml': Icons.data_object_outlined,
    'yml': Icons.data_object_outlined,
  };

  String get _extension {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ext = _extension;
    final icon = _icons[ext] ?? Icons.insert_drive_file_outlined;

    final double pad = dense ? 10 : 14;
    final double iconBox = dense ? 36 : 44;

    return MEPressable(
      onPressed: onPressed,
      color: scheme.surfaceContainerLow,
      shape:
          MEShapeScheme.fromCorner(dense ? MECorners.medium : MECorners.large),
      pressedShape: MEShapeScheme.fromCorner(MECorners.small),
      side: BorderSide(color: scheme.outlineVariant),
      overlayColor: scheme.primary.withValues(alpha: 0.08),
      semanticLabel: 'File: $name',
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(MECorners.medium),
              ),
              child: Icon(icon,
                  size: dense ? 20 : 24, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (dense
                            ? theme.textTheme.bodySmall
                            : theme.textTheme.bodyMedium)!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (size != null || ext.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      size ?? ext.toUpperCase(),
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onPressed != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.download_outlined,
                  size: dense ? 18 : 20, color: scheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}
