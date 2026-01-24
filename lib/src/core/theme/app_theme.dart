import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  // Using DeepBlue for a "Ocean/Cyan" vibe fitting the project name
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.light),
    scaffoldBackgroundColor: Colors.white,
  );

  static final dark = FlexThemeData.dark(scheme: FlexScheme.deepBlue, useMaterial3: true);
}
