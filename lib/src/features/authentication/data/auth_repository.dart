import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  const AuthRepository(this._supabase);

  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithGoogle() async {
    const webClientId = '942355627042-ovup1qisis9ecppeigp1mh10fijpce8c.apps.googleusercontent.com';

    // Google Sign In
    final googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final accessToken = googleAuth?.accessToken;
    final idToken = googleAuth?.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await _supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: accessToken);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
