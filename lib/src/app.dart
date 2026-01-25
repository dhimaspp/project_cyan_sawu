import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/authentication/data/auth_repository.dart';
import 'features/authentication/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🎨 MyApp building...');

    // Watch auth state to determine which page to show
    final authStateAsync = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Cyan',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(primary: Colors.cyan, surface: Colors.white),
      ),
      home: authStateAsync.when(
        data: (user) {
          debugPrint('🔐 Auth state: ${user != null ? 'logged in as ${user.email}' : 'not logged in'}');
          if (user != null) {
            return const HomePage();
          }
          return const LoginPage();
        },
        loading:
            () => const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading...')],
                ),
              ),
            ),
        error: (error, stack) {
          debugPrint('❌ Auth error: $error');
          return const LoginPage();
        },
      ),
    );
  }
}
