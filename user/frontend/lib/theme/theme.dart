import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6d538b),
      surfaceTint: Color(0xff6d538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffefdbff),
      onPrimaryContainer: Color(0xff553b71),
      secondary: Color(0xff655a6f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffecddf6),
      onSecondaryContainer: Color(0xff4d4357),
      tertiary: Color(0xff805159),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd9dd),
      onTertiaryContainer: Color(0xff653b41),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff1e1a20),
      onSurfaceVariant: Color(0xff4a454e),
      outline: Color(0xff7b757f),
      outlineVariant: Color(0xffccc4cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd9bafa),
      primaryFixed: Color(0xffefdbff),
      onPrimaryFixed: Color(0xff270d43),
      primaryFixedDim: Color(0xffd9bafa),
      onPrimaryFixedVariant: Color(0xff553b71),
      secondaryFixed: Color(0xffecddf6),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffd0c1da),
      onSecondaryFixedVariant: Color(0xff4d4357),
      tertiaryFixed: Color(0xffffd9dd),
      onTertiaryFixed: Color(0xff321017),
      tertiaryFixedDim: Color(0xfff3b7bf),
      onTertiaryFixedVariant: Color(0xff653b41),
      surfaceDim: Color(0xffdfd8e0),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff3ebf3),
      surfaceContainerHigh: Color(0xffeee6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff432a5f),
      surfaceTint: Color(0xff6d538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7d619b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3c3245),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff74697e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff522a31),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff906067),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff131015),
      onSurfaceVariant: Color(0xff39343d),
      outline: Color(0xff56505a),
      outlineVariant: Color(0xff716b74),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd9bafa),
      primaryFixed: Color(0xff7d619b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff634980),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff74697e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5b5165),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff906067),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff75484f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcbc4cc),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xffeee6ee),
      surfaceContainerHigh: Color(0xffe2dae2),
      surfaceContainerHighest: Color(0xffd7cfd7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff392055),
      surfaceTint: Color(0xff6d538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff573d74),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff32283b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4f4559),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff462127),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff683d44),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2f2a33),
      outlineVariant: Color(0xff4d4750),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd9bafa),
      primaryFixed: Color(0xff573d74),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff40265c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4f4559),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff382f42),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff683d44),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4e272e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbdb7be),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6eef6),
      surfaceContainer: Color(0xffe8e0e8),
      surfaceContainerHigh: Color(0xffd9d2da),
      surfaceContainerHighest: Color(0xffcbc4cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd9bafa),
      surfaceTint: Color(0xffd9bafa),
      onPrimary: Color(0xff3d2459),
      primaryContainer: Color(0xff553b71),
      onPrimaryContainer: Color(0xffefdbff),
      secondary: Color(0xffd0c1da),
      onSecondary: Color(0xff362d3f),
      secondaryContainer: Color(0xff4d4357),
      onSecondaryContainer: Color(0xffecddf6),
      tertiary: Color(0xfff3b7bf),
      onTertiary: Color(0xff4b252c),
      tertiaryContainer: Color(0xff653b41),
      onTertiaryContainer: Color(0xffffd9dd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff151218),
      onSurface: Color(0xffe8e0e8),
      onSurfaceVariant: Color(0xffccc4cf),
      outline: Color(0xff958e98),
      outlineVariant: Color(0xff4a454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff6d538b),
      primaryFixed: Color(0xffefdbff),
      onPrimaryFixed: Color(0xff270d43),
      primaryFixedDim: Color(0xffd9bafa),
      onPrimaryFixedVariant: Color(0xff553b71),
      secondaryFixed: Color(0xffecddf6),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffd0c1da),
      onSecondaryFixedVariant: Color(0xff4d4357),
      tertiaryFixed: Color(0xffffd9dd),
      onTertiaryFixed: Color(0xff321017),
      tertiaryFixedDim: Color(0xfff3b7bf),
      onTertiaryFixedVariant: Color(0xff653b41),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff3c383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1e1a20),
      surfaceContainer: Color(0xff221e24),
      surfaceContainerHigh: Color(0xff2c292e),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebd4ff),
      surfaceTint: Color(0xffd9bafa),
      onPrimary: Color(0xff32194e),
      primaryContainer: Color(0xffa285c1),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffe6d7f0),
      onSecondary: Color(0xff2b2234),
      secondaryContainer: Color(0xff998ca3),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd1d6),
      onTertiary: Color(0xff3e1a21),
      tertiaryContainer: Color(0xffb8838a),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe2d9e5),
      outline: Color(0xffb7afba),
      outlineVariant: Color(0xff958e98),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff563c73),
      primaryFixed: Color(0xffefdbff),
      onPrimaryFixed: Color(0xff1c0138),
      primaryFixedDim: Color(0xffd9bafa),
      onPrimaryFixedVariant: Color(0xff432a5f),
      secondaryFixed: Color(0xffecddf6),
      onSecondaryFixed: Color(0xff160d1f),
      secondaryFixedDim: Color(0xffd0c1da),
      onSecondaryFixedVariant: Color(0xff3c3245),
      tertiaryFixed: Color(0xffffd9dd),
      onTertiaryFixed: Color(0xff25060d),
      tertiaryFixedDim: Color(0xfff3b7bf),
      onTertiaryFixedVariant: Color(0xff522a31),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff474349),
      surfaceContainerLowest: Color(0xff09070b),
      surfaceContainerLow: Color(0xff201c22),
      surfaceContainer: Color(0xff2a272c),
      surfaceContainerHigh: Color(0xff353137),
      surfaceContainerHighest: Color(0xff403c42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff8ecff),
      surfaceTint: Color(0xffd9bafa),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffd5b6f6),
      onPrimaryContainer: Color(0xff15002c),
      secondary: Color(0xfff8ecff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffccbdd6),
      onSecondaryContainer: Color(0xff100819),
      tertiary: Color(0xffffebed),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeeb3bb),
      onTertiaryContainer: Color(0xff1d0308),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff6edf8),
      outlineVariant: Color(0xffc8c0cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff563c73),
      primaryFixed: Color(0xffefdbff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffd9bafa),
      onPrimaryFixedVariant: Color(0xff1c0138),
      secondaryFixed: Color(0xffecddf6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd0c1da),
      onSecondaryFixedVariant: Color(0xff160d1f),
      tertiaryFixed: Color(0xffffd9dd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff3b7bf),
      onTertiaryFixedVariant: Color(0xff25060d),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff534e55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff221e24),
      surfaceContainer: Color(0xff332f35),
      surfaceContainerHigh: Color(0xff3e3a40),
      surfaceContainerHighest: Color(0xff49454c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
