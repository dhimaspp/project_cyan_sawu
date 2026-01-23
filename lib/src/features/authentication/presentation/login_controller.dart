import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../data/wallet_repository.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // Listen to deep links for debugging/Manual Validation
    ref.listen(deepLinkProvider, (previous, next) {
      next.when(
        data: (link) {
          if (link != null) print("DEBUG: Deep Link Hit: $link");
        },
        error: (e, s) => print("Link Error: $e"),
        loading: () {},
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signInWithGoogle());
  }

  Future<void> connectWallet() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(walletRepositoryProvider).connectPhantom());
  }
}
