import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006a3c),
      surfaceTint: Color(0xff006d3e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00864d),
      onPrimaryContainer: Color(0xfff6fff5),
      secondary: Color(0xff755b00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffcc29),
      onSecondaryContainer: Color(0xff705700),
      tertiary: Color(0xff003d48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a5564),
      onTertiaryContainer: Color(0xff8bc8d9),
      error: Color(0xffad0037),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffdb0048),
      onErrorContainer: Color(0xffffeeee),
      surface: Color(0xfff5fbf3),
      onSurface: Color(0xff171d18),
      onSurfaceVariant: Color(0xff3e4a40),
      outline: Color(0xff6e7a70),
      outlineVariant: Color(0xffbdcabe),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322d),
      inversePrimary: Color(0xff6fdc99),
      primaryFixed: Color(0xff8cf9b3),
      onPrimaryFixed: Color(0xff00210f),
      primaryFixedDim: Color(0xff6fdc99),
      onPrimaryFixedVariant: Color(0xff00522d),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff241a00),
      secondaryFixedDim: Color(0xfff2c019),
      onSecondaryFixedVariant: Color(0xff584400),
      tertiaryFixed: Color(0xffafecfe),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xff93d0e1),
      onTertiaryFixedVariant: Color(0xff004e5d),
      surfaceDim: Color(0xffd6dcd4),
      surfaceBright: Color(0xfff5fbf3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ed),
      surfaceContainer: Color(0xffeaf0e8),
      surfaceContainerHigh: Color(0xffe4eae2),
      surfaceContainerHighest: Color(0xffdee4dc),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f21),
      surfaceTint: Color(0xff006d3e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff007e48),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff443400),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff876900),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003c48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a5564),
      onTertiaryContainer: Color(0xffc9f2ff),
      error: Color(0xff720021),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffdb0048),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf3),
      onSurface: Color(0xff0d120e),
      onSurfaceVariant: Color(0xff2e3930),
      outline: Color(0xff4a554c),
      outlineVariant: Color(0xff647066),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322d),
      inversePrimary: Color(0xff6fdc99),
      primaryFixed: Color(0xff007e48),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff006237),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff876900),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff695200),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff377585),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff185c6c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c1),
      surfaceBright: Color(0xfff5fbf3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ed),
      surfaceContainer: Color(0xffe4eae2),
      surfaceContainerHigh: Color(0xffd9ded7),
      surfaceContainerHighest: Color(0xffcdd3cc),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00341a),
      surfaceTint: Color(0xff006d3e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00552f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff382a00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b4600),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00313b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff005160),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5f001a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff96002e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf3),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff242f26),
      outlineVariant: Color(0xff404c43),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322d),
      inversePrimary: Color(0xff6fdc99),
      primaryFixed: Color(0xff00552f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b1f),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b4600),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff403100),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff005160),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003843),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab3),
      surfaceBright: Color(0xfff5fbf3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf2ea),
      surfaceContainer: Color(0xffdee4dc),
      surfaceContainerHigh: Color(0xffd0d6ce),
      surfaceContainerHighest: Color(0xffc2c8c1),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff6fdc99),
      surfaceTint: Color(0xff6fdc99),
      onPrimary: Color(0xff00391d),
      primaryContainer: Color(0xff33a467),
      onPrimaryContainer: Color(0xff000b03),
      secondary: Color(0xffffedc6),
      onSecondary: Color(0xff3d2e00),
      secondaryContainer: Color(0xffffcc29),
      onSecondaryContainer: Color(0xff705700),
      tertiary: Color(0xff93d0e1),
      onTertiary: Color(0xff003640),
      tertiaryContainer: Color(0xff0a5564),
      onTertiaryContainer: Color(0xff8bc8d9),
      error: Color(0xffffb2b8),
      onError: Color(0xff67001d),
      errorContainer: Color(0xffdb0048),
      onErrorContainer: Color(0xffffeeee),
      surface: Color(0xff0f1510),
      onSurface: Color(0xffdee4dc),
      onSurfaceVariant: Color(0xffbdcabe),
      outline: Color(0xff879489),
      outlineVariant: Color(0xff3e4a40),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4dc),
      inversePrimary: Color(0xff006d3e),
      primaryFixed: Color(0xff8cf9b3),
      onPrimaryFixed: Color(0xff00210f),
      primaryFixedDim: Color(0xff6fdc99),
      onPrimaryFixedVariant: Color(0xff00522d),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff241a00),
      secondaryFixedDim: Color(0xfff2c019),
      onSecondaryFixedVariant: Color(0xff584400),
      tertiaryFixed: Color(0xffafecfe),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xff93d0e1),
      onTertiaryFixedVariant: Color(0xff004e5d),
      surfaceDim: Color(0xff0f1510),
      surfaceBright: Color(0xff353b35),
      surfaceContainerLowest: Color(0xff0a0f0b),
      surfaceContainerLow: Color(0xff171d18),
      surfaceContainer: Color(0xff1b211c),
      surfaceContainerHigh: Color(0xff252b26),
      surfaceContainerHighest: Color(0xff303631),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff86f2ad),
      surfaceTint: Color(0xff6fdc99),
      onPrimary: Color(0xff002d16),
      primaryContainer: Color(0xff33a467),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffedc6),
      onSecondary: Color(0xff3d2e00),
      secondaryContainer: Color(0xffffcc29),
      onSecondaryContainer: Color(0xff4e3c00),
      tertiary: Color(0xffa9e6f8),
      onTertiary: Color(0xff002a33),
      tertiaryContainer: Color(0xff5d99aa),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd1d4),
      onError: Color(0xff530016),
      errorContainer: Color(0xffff506e),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1510),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd3e0d3),
      outline: Color(0xffa9b5a9),
      outlineVariant: Color(0xff879388),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4dc),
      inversePrimary: Color(0xff00532e),
      primaryFixed: Color(0xff8cf9b3),
      onPrimaryFixed: Color(0xff001508),
      primaryFixedDim: Color(0xff6fdc99),
      onPrimaryFixedVariant: Color(0xff003f21),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff181000),
      secondaryFixedDim: Color(0xfff2c019),
      onSecondaryFixedVariant: Color(0xff443400),
      tertiaryFixed: Color(0xffafecfe),
      onTertiaryFixed: Color(0xff001419),
      tertiaryFixedDim: Color(0xff93d0e1),
      onTertiaryFixedVariant: Color(0xff003c48),
      surfaceDim: Color(0xff0f1510),
      surfaceBright: Color(0xff404640),
      surfaceContainerLowest: Color(0xff040805),
      surfaceContainerLow: Color(0xff191f1a),
      surfaceContainer: Color(0xff232924),
      surfaceContainerHigh: Color(0xff2e342f),
      surfaceContainerHighest: Color(0xff393f3a),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbeffd0),
      surfaceTint: Color(0xff6fdc99),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff6bd895),
      onPrimaryContainer: Color(0xff000b03),
      secondary: Color(0xffffeecb),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffcc29),
      onSecondaryContainer: Color(0xff271c00),
      tertiary: Color(0xffd6f5ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff8fccdd),
      onTertiaryContainer: Color(0xff000d12),
      error: Color(0xffffebec),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffadb3),
      onErrorContainer: Color(0xff210005),
      surface: Color(0xff0f1510),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe7f3e6),
      outlineVariant: Color(0xffb9c6ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4dc),
      inversePrimary: Color(0xff00532e),
      primaryFixed: Color(0xff8cf9b3),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff6fdc99),
      onPrimaryFixedVariant: Color(0xff001508),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xfff2c019),
      onSecondaryFixedVariant: Color(0xff181000),
      tertiaryFixed: Color(0xffafecfe),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff93d0e1),
      onTertiaryFixedVariant: Color(0xff001419),
      surfaceDim: Color(0xff0f1510),
      surfaceBright: Color(0xff4b524c),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211c),
      surfaceContainer: Color(0xff2c322d),
      surfaceContainerHigh: Color(0xff373d37),
      surfaceContainerHighest: Color(0xff424843),
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
     scaffoldBackgroundColor: colorScheme.surface,
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
