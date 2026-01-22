# Project Context

## Purpose
Project Cyan is a decentralized Digital Monitoring, Reporting, and Verification (dMRV) infrastructure for blue carbon assets (Seagrass/Lamun) in Indonesia.
The application serves as a "Point of Truth" mobile client that bridges physical field conditions with blockchain data integrity. Its primary goals are to enable trustless data collection, support a hybrid user experience (Web2 + Web3), and ensure connectivity resilience in low-bandwidth environments (offline-first).

## Tech Stack
- **Languages**: Dart (Null Safety enabled)
- **Framework**: Flutter (Mobile: iOS & Android)
- **State Management**: Riverpod (with Code Generation)
- **Backend (BaaS)**: Supabase (PostgreSQL, Auth, Storage)
- **Blockchain**: Solana (Wallet Adapter for identity linkage)
- **Local Database**: Hive (NoSQL)
- **Mapping**: flutter_map (OpenStreetMap)
- **Authentication**: Supabase Auth (Email/Social) + Solana Wallet (Phantom/Solflare)

## Project Conventions

### Code Style
- Follow standard Dart/Flutter linting rules.
- Use `riverpod_annotation` for generating providers.
- Strict typing and Null Safety are mandatory.

### Architecture Patterns
- **Feature-First Structure**: Organize code by features (e.g., `features/auth`, `features/camera`, `features/sync`) rather than layer-first.
- **Repository Pattern**: Use Repositories to abstract data sources (Supabase vs Hive).
- **Dependency Injection**: Use `get_it` for service location and dependency injection.
- **Offline-First**: Always write to local storage (Hive) first or queue actions if offline.

### Testing Strategy
- **Unit Tests**: Required for core logic (Hashing, Queue management).
- **Widget Tests**: Focus on critical UI constraints (e.g., ensuring Camera screen has no Gallery picker).
- **Field Simulation**: Real-world testing in low web connectivity.

### Git Workflow
- Standard feature-branch workflow.
- Commit messages should be descriptive.

## Domain Context
- **dMRV**: Digital Monitoring, Reporting, and Verification. Critical for carbon credit markets.
- **Blue Carbon**: Carbon stored in coastal and marine ecosystems (specifically Seagrass/Lamun).
- **Proof of Location**: Requires high-integrity GPS and anti-spoofing measures (`isMockLocation` checks).
- **Proof of Time**: Timestamps must be trusted and hashed immediately.

## Important Constraints
- **No Gallery Uploads**: To prevent fake data, the app must ONLY allow camera capture. Gallery access is hard-disabled.
- **Offline Resilience**: The app is often used in the middle of the sea. It must be fully functional for data capture without signal.
- **Low-Cost Device Support**: Must run smoothly on mid-range Android devices (e.g., Samsung Galaxy A50 class).

## External Dependencies
- **Supabase**: Primary backend for Relational DB, Auth, and Storage.
- **OpenStreetMap**: Map tiles source.
- **Solana Network**: For wallet connection verification.
- **Geolocator**: For high-accuracy GPS coordinates.
