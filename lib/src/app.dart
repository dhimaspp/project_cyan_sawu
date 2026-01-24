import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/features/authentication/presentation/login_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🎨 MyApp building...');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Cyan',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(primary: Colors.cyan, surface: Colors.white),
      ),
      home: const LoginPage(),
    );
  }
}
