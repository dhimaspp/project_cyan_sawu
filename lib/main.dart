import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Get Supabase credentials from .env
  final supabaseUrl = dotenv.env['PUBLIC_SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing Supabase credentials in .env file');
  }

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Supabase init failed: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}
