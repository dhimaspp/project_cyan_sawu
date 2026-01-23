# Spec: Authentication

## ADDED Requirements

### Requirement: [AUTH-001] Hybrid Login
Users MUST be able to log in with standard Web2 methods.

#### Scenario: User logs in with Email
- **Given** I am on the Login Page
- **When** I enter my email and password and click "Sign In"
- **Then** I should be authenticated via Supabase Auth and redirected to the Home Screen.

### Requirement: [AUTH-002] Wallet Connection
Users SHALL be able to link a Solana Wallet for verification.

#### Scenario: Connect Phantom
- **Given** I am logged in
- **When** I click "Connect Wallet"
- **Then** The Phantom App (if installed) should open asking for a signature.
