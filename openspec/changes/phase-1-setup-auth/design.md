# Design: Phase 1 Architecture

## Architecture Pattern
We will adhere to the **Feature-First** architecture as specified in `openspec/project.md`.

### Directory Structure
```
lib/
├── src/
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── core/
│   │       ├── application/
│   │       └── data/
│   └── app.dart
```

## State Management
- **Riverpod** (Generator syntax) will be used for all state.
- `AuthRepository` will be exposed via a Provider.
- `AuthState` will be reactive, listening to Supabase `onAuthStateChange`.

## Authentication Flow
1. **Repository Layer**:
   - `AuthRepository`: Wraps `Supabase.auth`.
   - `WalletRepository`: Handles `url_launcher` deep links to Phantom.
2. **Logic Layer**:
   - `AuthController`: Manages loading states, error handling, and navigation routing.
3. **UI Layer**:
   - `LoginPage`: Clean UI with "Sign in with Google" and secondary "Connect Wallet" option.

## Deep Link Strategy (Solana)
- Use `dapp://` scheme for triggering Phantom.
- Callback handled via `uni_links` or standard Flutter Deep Linking to capture the `signature`.
