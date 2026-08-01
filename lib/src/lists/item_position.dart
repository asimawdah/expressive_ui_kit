import 'package:flutter/material.dart';

enum ItemPosition {
  alone,
  start,
  center,
  end,
  left,
  right,
  top,
  bottom,
  bottomLeft,
  bottomRight;

  EdgeInsets get padding {
    return switch (this) {
      ItemPosition.alone => EdgeInsets.zero,
      ItemPosition.start => const EdgeInsets.only(top: 0, bottom: 2),
      ItemPosition.center => const EdgeInsets.only(top: 2, bottom: 2),
      ItemPosition.end => const EdgeInsets.only(top: 2, bottom: 0),
      ItemPosition.left => const EdgeInsets.only(right: 2),
      ItemPosition.right => const EdgeInsets.only(left: 2),
      ItemPosition.top => const EdgeInsets.only(bottom: 2),
      ItemPosition.bottom => const EdgeInsets.only(top: 2),
      ItemPosition.bottomLeft => const EdgeInsets.only(top: 2),
      ItemPosition.bottomRight => const EdgeInsets.only(top: 2),
    };
  }

  BorderRadius get borderRadius {
    return switch (this) {
      ItemPosition.alone => BorderRadius.circular(24),
      ItemPosition.start => const BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(8),
        ),
      ItemPosition.center => BorderRadius.circular(8),
      ItemPosition.end => const BorderRadius.vertical(
          top: Radius.circular(8),
          bottom: Radius.circular(24),
        ),
      ItemPosition.left => const BorderRadius.horizontal(
          left: Radius.circular(24),
          right: Radius.circular(8),
        ),
      ItemPosition.right => const BorderRadius.horizontal(
          left: Radius.circular(8),
          right: Radius.circular(24),
        ),
      ItemPosition.top => const BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(8),
        ),
      ItemPosition.bottom => const BorderRadius.vertical(
          top: Radius.circular(8),
          bottom: Radius.circular(24),
        ),
      ItemPosition.bottomLeft => const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(8),
        ),
      ItemPosition.bottomRight => const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(24),
        ),
    };
  }

  BorderRadius customBorderRadius(bool isArabic) {
    if (isArabic) {
      switch (this) {
        case ItemPosition.start:
          return borderRadius.copyWith(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(8),
          );
        case ItemPosition.end:
          return borderRadius.copyWith(
            bottomRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(8),
          );
        case ItemPosition.alone:
          return borderRadius.copyWith(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(8),
            bottomRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(8),
          );
        default:
          return borderRadius;
      }
    } else {
      switch (this) {
        case ItemPosition.start:
          return borderRadius.copyWith(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(8),
          );
        case ItemPosition.end:
          return borderRadius.copyWith(
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(8),
          );
        case ItemPosition.alone:
          return borderRadius.copyWith(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(8),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(8),
          );
        default:
          return borderRadius;
      }
    }
  }

  factory ItemPosition.fromIndex(int index, int length) {
    if (length == 1) {
      return ItemPosition.alone;
    } else if (index == 0) {
      return ItemPosition.start;
    } else if (index == length - 1) {
      return ItemPosition.end;
    } else {
      return ItemPosition.center;
    }
  }
}
