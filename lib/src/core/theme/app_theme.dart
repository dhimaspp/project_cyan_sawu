import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Using DeepBlue for a "Ocean/Cyan" vibe fitting the project name
  static final light = FlexThemeData.light(
    scheme: FlexScheme.deepBlue,
    useMaterial3: true,
    fontFamily: 'GoogleFonts.inter().fontFamily', // Placeholder for now
  );
  static final dark = FlexThemeData.dark(
    scheme: FlexScheme.deepBlue,
    useMaterial3: true,
    fontFamily: 'GoogleFonts.inter().fontFamily',
  );
}
