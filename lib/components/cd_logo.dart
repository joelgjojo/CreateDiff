import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Supported visual variants of the official CreateDiff brand identity.
enum CDLogoVariant {
  /// Standalone CD symbol
  monogram,

  /// Standalone CreateDiff wordmark
  wordmark,

  /// CD symbol + CreateDiff wordmark lockup
  lockup,
}

/// Color modes for rendering the brand assets across diverse UI backgrounds.
enum CDLogoColorMode {
  /// Vibrant brand electric blue-violet (#4F43F9)
  brand,

  /// Context-aware: crisp white on dark surfaces, dark graphite on light surfaces
  adaptive,

  /// Pure white for high contrast on dark backgrounds
  white,

  /// Dark graphite (#111318) for high contrast on light backgrounds
  dark,
}

/// Unified, reusable brand logo component for CreateDiff.
///
/// Ensures pixel-perfect fidelity, semantic accessibility, theme adaptability,
/// and responsive scaling across all screens and overlays.
class CDLogo extends StatelessWidget {
  final CDLogoVariant variant;
  final CDLogoColorMode colorMode;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? semanticLabel;
  final bool isHero;
  final String? heroTag;

  const CDLogo({
    super.key,
    this.variant = CDLogoVariant.monogram,
    this.colorMode = CDLogoColorMode.adaptive,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.isHero = false,
    this.heroTag,
  });

  const CDLogo.monogram({
    super.key,
    this.colorMode = CDLogoColorMode.adaptive,
    this.height = 28,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'CreateDiff Monogram',
    this.isHero = false,
    this.heroTag,
  }) : variant = CDLogoVariant.monogram;

  const CDLogo.wordmark({
    super.key,
    this.colorMode = CDLogoColorMode.adaptive,
    this.height = 24,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'CreateDiff Wordmark',
    this.isHero = false,
    this.heroTag,
  }) : variant = CDLogoVariant.wordmark;

  const CDLogo.lockup({
    super.key,
    this.colorMode = CDLogoColorMode.adaptive,
    this.height = 28,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'CreateDiff Logo',
    this.isHero = false,
    this.heroTag,
  }) : variant = CDLogoVariant.lockup;

  String _getAssetPath(BuildContext context) {
    final isDarkTheme = CDColors.isDark(context);

    String colorSuffix;
    switch (colorMode) {
      case CDLogoColorMode.brand:
        colorSuffix = 'blue_violet';
        break;
      case CDLogoColorMode.white:
        colorSuffix = 'white';
        break;
      case CDLogoColorMode.dark:
        colorSuffix = 'dark';
        break;
      case CDLogoColorMode.adaptive:
        colorSuffix = isDarkTheme ? 'white' : 'dark';
        break;
    }

    switch (variant) {
      case CDLogoVariant.monogram:
        return 'assets/branding/monogram/cd_monogram_$colorSuffix.png';
      case CDLogoVariant.wordmark:
        return 'assets/branding/wordmark/cd_wordmark_$colorSuffix.png';
      case CDLogoVariant.lockup:
        return 'assets/branding/lockup/cd_lockup_$colorSuffix.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath(context);
    final label = semanticLabel ?? _defaultLabel();

    Widget logoWidget = Semantics(
      label: label,
      image: true,
      child: Image.asset(
        assetPath,
        height: height,
        width: width,
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );

    if (isHero) {
      logoWidget = Hero(
        tag: heroTag ?? 'creatediff_logo_${variant.name}',
        child: logoWidget,
      );
    }

    return logoWidget;
  }

  String _defaultLabel() {
    switch (variant) {
      case CDLogoVariant.monogram:
        return 'CreateDiff CD';
      case CDLogoVariant.wordmark:
        return 'CreateDiff';
      case CDLogoVariant.lockup:
        return 'CreateDiff Studio';
    }
  }
}
