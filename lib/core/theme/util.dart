import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(BuildContext context, String bodyFontString, String displayFontString) {
  final TextTheme baseTextTheme = Theme.of(context).textTheme;
  final TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  final TextTheme displayTextTheme = GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
  final TextTheme textTheme = displayTextTheme.copyWith(
    displayLarge: displayTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
    displayMedium: displayTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
    displaySmall: displayTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
    headlineLarge: displayTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
    headlineMedium: displayTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    headlineSmall: displayTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
    titleLarge: displayTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    titleMedium: displayTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    titleSmall: bodyTextTheme.titleSmall,
  );
  return textTheme;
}
