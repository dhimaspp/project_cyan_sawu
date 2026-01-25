# Tasks: Add Home Navigation

## Task 1: Create HomePage Widget ✅
**Scope**: `lib/src/features/home/presentation/home_page.dart`

Create minimal `HomePage` with:
- Welcome header with user email ✓
- "Capture Report" button (primary action, full-width) ✓
- Sign out button in app bar with confirmation dialog ✓

**Validation**: Widget renders correctly ✓

---

## Task 2: Update App Navigation ✅
**Scope**: `lib/src/app.dart`

Modify `MyApp` to:
- Watch `authStateProvider` stream ✓
- Show `LoginPage` when user is null (not authenticated) ✓
- Show `HomePage` when user is authenticated ✓
- Show loading indicator while checking initial auth state ✓

**Note**: Supabase automatically restores persisted sessions on startup, so `authStateProvider` will emit the saved user if they were previously logged in.

**Validation**: Navigation works on auth state change ✓

---

## Task 3: Add Camera Navigation ✅
**Scope**: `lib/src/features/home/presentation/home_page.dart`

Wire "Capture Report" button to navigate to `CameraPage`. ✓

**Validation**: Tapping button opens camera screen ✓

---

## Task 4: Implement Logout with Confirmation ✅
**Scope**: `lib/src/features/home/presentation/home_page.dart`

Add logout functionality:
- Show confirmation dialog before signing out ✓
- Call `authRepository.signOut()` on confirmation ✓
- Navigation to LoginPage happens automatically via auth state ✓

**Validation**: Logout works with confirmation ✓

---

## Task 5: Manual Testing 🔄
- [ ] Login → HomePage shown
- [ ] User email displayed on HomePage
- [ ] Capture button → Camera opens
- [ ] Logout button → Confirmation dialog shown
- [ ] Confirm logout → LoginPage shown
- [ ] Kill app and reopen → HomePage shown (session persisted)
- [ ] Cold start when logged in → HomePage shown directly

**Validation**: All flows work correctly

**Note**: Build successful. APK available at `build/app/outputs/flutter-apk/app-debug.apk`
