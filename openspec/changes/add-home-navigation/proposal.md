# Proposal: Add Home Navigation

## Summary
Add a minimal home page that users are navigated to after successful login, with a button to access the camera feature for field report capture. Include logout functionality and persistent session support.

## Motivation
Currently, the app shows `LoginPage` as the home and there's no post-login experience. Users need:
1. A place to land after authentication
2. A way to access the camera capture feature
3. Ability to log out
4. Persistent session so they don't need to re-login on every app launch

## Scope

### In Scope
- Create minimal `HomePage` widget
- Add auth-based navigation (show LoginPage if not logged in, HomePage if logged in)
- Add "Capture Report" button on HomePage that navigates to CameraPage
- Add sign out (logout) functionality with confirmation
- Session persistence (Supabase handles this automatically, we just need to check on startup)

### Out of Scope
- Dashboard analytics
- Report history list
- Map view (Phase 3)

## Success Criteria
1. After successful Google Sign-In, user is navigated to HomePage
2. HomePage displays welcome message and user info (email)
3. "Capture Report" button opens CameraPage
4. Logout button in app bar with confirmation dialog
5. On app restart, if user was logged in, they go directly to HomePage (no re-login needed)

## Dependencies
- Phase 1 (Auth) ✓
- Phase 2 (Camera) ✓

## Technical Notes
- Supabase Flutter SDK automatically persists sessions in secure storage
- `authStateProvider` will emit the persisted user on app startup
- No additional storage setup required
