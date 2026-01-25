# Spec: Project Foundation

## ADDED Requirements

### Requirement: [FND-001] Feature-First Architecture
The codebase MUST be organized by features to support scalability.

#### Scenario: Developer adds new feature
- **Given** I am a developer adding a "Camera" feature
- **When** I look at the `lib/src/features` directory
- **Then** I should see a `camera` folder waiting to be populated, distinct from `authentication`.

### Requirement: [FND-002] Supabase Initialization
The app MUST initialize Supabase before the UI renders.

#### Scenario: App Launch
- **Given** The app is just opened
- **When** The `main()` function executes
- **Then** `Supabase.initialize` must be called with valid URL and Anon Key.
