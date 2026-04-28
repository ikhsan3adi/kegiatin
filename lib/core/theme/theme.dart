import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff405f91),
      surfaceTint: Color(0xff405f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd6e3ff),
      onPrimaryContainer: Color(0xff274777),
      secondary: Color(0xff745b0c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdf90),
      onSecondaryContainer: Color(0xff584400),
      tertiary: Color(0xff00687a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffadecff),
      onTertiaryContainer: Color(0xff004e5d),
      error: Color(0xff8f4a51),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdadb),
      onErrorContainer: Color(0xff72333a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff44474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff274777),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff241a00),
      secondaryFixedDim: Color(0xffe4c36c),
      onSecondaryFixedVariant: Color(0xff584400),
      tertiaryFixed: Color(0xffadecff),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xff85d2e7),
      onTertiaryFixedVariant: Color(0xff004e5d),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff123665),
      surfaceTint: Color(0xff405f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff506da0),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff443400),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff846a1c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003c48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1e778a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e222b),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa0585f),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff4f525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff506da0),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff365586),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff846a1c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff695200),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff1e778a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff005d6e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe7e8ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff022b5b),
      surfaceTint: Color(0xff405f91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2a497a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff382a00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b4600),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00313b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff005160),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511921),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff75353d),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff2a497a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0d3262),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b4600),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff403100),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff005160),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003843),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd3d4db),
      surfaceContainerHighest: Color(0xffc5c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff09305f),
      primaryContainer: Color(0xff274777),
      onPrimaryContainer: Color(0xffd6e3ff),
      secondary: Color(0xffe4c36c),
      onSecondary: Color(0xff3d2e00),
      secondaryContainer: Color(0xff584400),
      onSecondaryContainer: Color(0xffffdf90),
      tertiary: Color(0xff85d2e7),
      onTertiary: Color(0xff003640),
      tertiaryContainer: Color(0xff004e5d),
      onTertiaryContainer: Color(0xffadecff),
      error: Color(0xffffb2b8),
      onError: Color(0xff561d25),
      errorContainer: Color(0xff72333a),
      onErrorContainer: Color(0xffffdadb),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff405f91),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff274777),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff241a00),
      secondaryFixedDim: Color(0xffe4c36c),
      onSecondaryFixedVariant: Color(0xff584400),
      tertiaryFixed: Color(0xffadecff),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xff85d2e7),
      onTertiaryFixedVariant: Color(0xff004e5d),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdddff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff002550),
      primaryContainer: Color(0xff7491c6),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffbd980),
      onSecondary: Color(0xff302400),
      secondaryContainer: Color(0xffaa8d3d),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff9be8fe),
      onTertiary: Color(0xff002a33),
      tertiaryContainer: Color(0xff4c9baf),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd1d4),
      onError: Color(0xff48121b),
      errorContainer: Color(0xffca7a82),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce6),
      outline: Color(0xffafb2bb),
      outlineVariant: Color(0xff8d9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff284878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff00112b),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff123665),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff181000),
      secondaryFixedDim: Color(0xffe4c36c),
      onSecondaryFixedVariant: Color(0xff443400),
      tertiaryFixed: Color(0xffadecff),
      onTertiaryFixed: Color(0xff001419),
      tertiaryFixedDim: Color(0xff85d2e7),
      onTertiaryFixedVariant: Color(0xff003c48),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff42444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1b1e22),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff303238),
      surfaceContainerHighest: Color(0xff3c3e43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa5c3fc),
      onPrimaryContainer: Color(0xff000b20),
      secondary: Color(0xffffeecb),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe0bf69),
      onSecondaryContainer: Color(0xff100a00),
      tertiary: Color(0xffd6f5ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff81cee3),
      onTertiaryContainer: Color(0xff000d12),
      error: Color(0xffffebec),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffadb3),
      onErrorContainer: Color(0xff210005),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff284878),
      primaryFixed: Color(0xffd6e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00112b),
      secondaryFixed: Color(0xffffdf90),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe4c36c),
      onSecondaryFixedVariant: Color(0xff181000),
      tertiaryFixed: Color(0xffadecff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff85d2e7),
      onTertiaryFixedVariant: Color(0xff001419),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1d2024),
      surfaceContainer: Color(0xff2e3036),
      surfaceContainerHigh: Color(0xff393b41),
      surfaceContainerHighest: Color(0xff45474c),
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

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xfffff3c4),
    value: Color(0xfffff3c4),
    light: ColorFamily(
      color: Color(0xff6c5e10),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff6e388),
      onColorContainer: Color(0xff524700),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff6c5e10),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff6e388),
      onColorContainer: Color(0xff524700),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff6c5e10),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff6e388),
      onColorContainer: Color(0xff524700),
    ),
    dark: ColorFamily(
      color: Color(0xffd9c76f),
      onColor: Color(0xff393000),
      colorContainer: Color(0xff524700),
      onColorContainer: Color(0xfff6e388),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffd9c76f),
      onColor: Color(0xff393000),
      colorContainer: Color(0xff524700),
      onColorContainer: Color(0xfff6e388),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffd9c76f),
      onColor: Color(0xff393000),
      colorContainer: Color(0xff524700),
      onColorContainer: Color(0xfff6e388),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(0xffade7a6),
    value: Color(0xffade7a6),
    light: ColorFamily(
      color: Color(0xff3b693a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3b693a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3b693a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    dark: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff09390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff09390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff09390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
  );

  /// Custom Color 3
  static const customColor3 = ExtendedColor(
    seed: Color(0xffb7d7ff),
    value: Color(0xffb7d7ff),
    light: ColorFamily(
      color: Color(0xff34618e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd1e4ff),
      onColorContainer: Color(0xff174974),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff34618e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd1e4ff),
      onColorContainer: Color(0xff174974),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff34618e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd1e4ff),
      onColorContainer: Color(0xff174974),
    ),
    dark: ColorFamily(
      color: Color(0xff9fcafc),
      onColor: Color(0xff003257),
      colorContainer: Color(0xff174974),
      onColorContainer: Color(0xffd1e4ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff9fcafc),
      onColor: Color(0xff003257),
      colorContainer: Color(0xff174974),
      onColorContainer: Color(0xffd1e4ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff9fcafc),
      onColor: Color(0xff003257),
      colorContainer: Color(0xff174974),
      onColorContainer: Color(0xffd1e4ff),
    ),
  );

  /// Custom Color 4
  static const customColor4 = ExtendedColor(
    seed: Color(0xffff8794),
    value: Color(0xffff8794),
    light: ColorFamily(
      color: Color(0xff8f4a51),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadb),
      onColorContainer: Color(0xff72333a),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff8f4a51),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadb),
      onColorContainer: Color(0xff72333a),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff8f4a51),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdadb),
      onColorContainer: Color(0xff72333a),
    ),
    dark: ColorFamily(
      color: Color(0xffffb2b8),
      onColor: Color(0xff561d25),
      colorContainer: Color(0xff72333a),
      onColorContainer: Color(0xffffdadb),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb2b8),
      onColor: Color(0xff561d25),
      colorContainer: Color(0xff72333a),
      onColorContainer: Color(0xffffdadb),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb2b8),
      onColor: Color(0xff561d25),
      colorContainer: Color(0xff72333a),
      onColorContainer: Color(0xffffdadb),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
    customColor2,
    customColor3,
    customColor4,
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
