import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with actual Project URL and Anon Key from Supabase Dashboard
  const supabaseUrl = 'https://placeholder.supabase.co';
  const supabaseAnonKey = 'placeholder_key';

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    debugPrint('Supabase init failed (expected if no real keys): $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}
