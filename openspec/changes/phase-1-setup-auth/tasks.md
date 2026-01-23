# Tasks: Phase 1 Implementation

## Foundation
- [x] Initialize Flutter project (if not already verified): `flutter create .`
- [x] Add dependencies: `flutter_riverpod`, `riverpod_annotation`, `supabase_flutter`, `url_launcher`, `uni_links`, `crypto`.
- [x] Configure `dev_dependencies`: `build_runner`, `riverpod_generator`, `flutter_lints`.
- [x] Create basic folder structure (`lib/src/features`, `lib/src/core`).

## Authentication
- [x] Implement `CoreWrapper` (Initialize Supabase).
- [x] Create `AuthRepository` interface and implementation.
- [x] implementation Stream<User?> authStateChanges.
- [x] Implement `LoginController` (Riverpod StateNotifier/AsyncNotifier).

## UI
- [x] Create `Theme` config (Material 3 + FlexColorScheme).
- [x] Build `LoginPage` widget.
- [x] Add "Sign in with Google/Email" buttons.
- [x] Add "Connect Wallet" button (initially just logs log).

## Wallet Integration
- [x] Implement `WalletRepository` for Phantom Deep Link.
- [x] Create `SolanaAuthService` to construct `SignMessage` payload.
- [x] Validating Deep Link return manually (console log).
