import 'package:flutter/material.dart';

import '../progress/me_skeleton.dart';
import '../theme/me_shapes.dart';

/// A Material 3 Expressive network image.
///
/// Wraps [Image.network] with an M3E rounded container, a shimmering
/// [MESkeleton] while loading, a graceful broken-image fallback, and a
/// fade-in when the image arrives. Used by [MEMarkdown] for `![alt](url)`
/// images; also works standalone.
class MEImage extends StatelessWidget {
  const MEImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.radius = MECorners.large,
    this.semanticLabel,
  });

  final String url;
  final double? width;
  final double? height;

  /// Used when [height] is null to reserve space while loading.
  final double? aspectRatio;

  final BoxFit fit;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return MESkeleton(
          width: width ?? double.infinity,
          height: height ?? 180,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height ?? 120,
        color: scheme.surfaceContainerHigh,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined,
                color: scheme.onSurfaceVariant),
            if (semanticLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                semanticLabel!,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );

    if (height == null && aspectRatio != null) {
      image = AspectRatio(aspectRatio: aspectRatio!, child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}
