import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

/// Payment card using [CreditCardWidget] defaults (glass theme, padding, layout).
class MECreditCard extends StatelessWidget {
  const MECreditCard({
    super.key,
    required this.number,
    required this.holder,
    required this.expiry,
    this.cvc = '',
    this.bankName,
    this.brand,
    this.showBackView = false,
    this.interactive = true,
    this.obscureNumber = true,
    this.obscureCvv = true,
    this.border,
  });

  /// Library card aspect (height / width).
  static const double aspectRatio = 0.5714;

  /// Grid `childAspectRatio` matching the default card plus 16px padding.
  static const double gridChildAspectRatio =
      340 / ((340 - 32) * aspectRatio + 32);

  final String number;
  final String holder;
  final String expiry;
  final String cvc;
  final String? bankName;

  /// Network brand (`visa`, `mastercard`, `amex`, `discover`, `unionpay`,
  /// `rupay`, `elo`, `hipercard`, `mir`).
  ///
  /// When set, that logo is shown even if the number is not a known BIN.
  /// Unrecognized brands show no logo.
  final String? brand;
  final bool showBackView;
  final bool interactive;
  final bool obscureNumber;
  final bool obscureCvv;
  final BoxBorder? border;

  String get _spacedNumber {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  CardType? get _cardType => switch (brand?.toLowerCase().trim()) {
        'visa' => CardType.visa,
        'mastercard' || 'maestro' => CardType.mastercard,
        'amex' ||
        'americanexpress' ||
        'american express' =>
          CardType.americanExpress,
        'discover' => CardType.discover,
        'unionpay' || 'union pay' => CardType.unionpay,
        'rupay' || 'ru pay' => CardType.rupay,
        'elo' => CardType.elo,
        'hipercard' => CardType.hipercard,
        'mir' => CardType.mir,
        _ => null,
      };

  String get _expiry {
    final raw = expiry.trim();
    if (raw.contains('/')) return raw;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(2, 4)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final glass = _glassFor(scheme, isLight);

    return CreditCardWidget(
      cardNumber: _spacedNumber,
      expiryDate: _expiry,
      cardHolderName: holder.trim(),
      cvvCode: cvc.trim(),
      showBackView: showBackView,
      onCreditCardWidgetChange: (_) {},
      bankName: bankName?.trim().isEmpty ?? true ? null : bankName!.trim(),
      cardType: _cardType,
      glassmorphismConfig: glass,
      cardBgColor:
          isLight ? scheme.surfaceContainerHigh : const Color(0xFF2C2C2C),
      textStyle: isLight
          ? theme.textTheme.titleLarge?.merge(
              TextStyle(
                color: scheme.onSurface,
                fontFamily: 'halter',
                fontSize: 15,
                letterSpacing: 0.8,
                package: 'flutter_credit_card',
              ),
            )
          : null,
      isHolderNameVisible: true,
      obscureCardNumber: obscureNumber,
      obscureCardCvv: obscureCvv,
      isSwipeGestureEnabled: interactive,
      enableFloatingCard: true,
      floatingConfig: FloatingConfig(
        shadowConfig: FloatingShadowConfig(
          offset: Offset(0, isLight ? 10 : 8),
          blurRadius: isLight ? 28 : 16,
          color: scheme.shadow.withValues(alpha: isLight ? 0.10 : 0.38),
        ),
      ),
      animationDuration: const Duration(milliseconds: 500),
      frontCardBorder: border ??
          Border.all(
            width: 1.15,
            color: isLight
                ? Colors.white.withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.22),
          ),
      backCardBorder: border ??
          Border.all(
            width: 1.15,
            color: isLight
                ? Colors.white.withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.22),
          ),
    );
  }

  static Glassmorphism _glassFor(ColorScheme scheme, bool isLight) {
    if (isLight) {
      return Glassmorphism(
        blurX: 18,
        blurY: 24,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.78),
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.52),
            ),
            scheme.primaryContainer.withValues(alpha: 0.42),
          ],
          stops: const <double>[0.0, 0.48, 1.0],
        ),
      );
    }

    return Glassmorphism(
      blurX: 12,
      blurY: 20,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.16),
          scheme.surfaceContainerHighest.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.06),
        ],
        stops: const <double>[0.0, 0.5, 1.0],
      ),
    );
  }
}
