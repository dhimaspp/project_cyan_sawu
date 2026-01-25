# Proposal: Phase 2 – The Core "Prover"

## Summary
Implement the core dMRV "Prover" module that enables trustless field data collection. This phase delivers a secure camera system with anti-spoofing measures, real-time watermarking of captured images, and cryptographic hashing for data integrity verification.

## Motivation
The PRD identifies data integrity as a critical requirement. Verifiers and auditors must be able to confirm that photos were:
1. Captured at the claimed location (not uploaded from gallery or spoofed GPS)
2. Taken at the claimed time
3. Not manipulated after capture

This phase implements the technical foundation for these guarantees.

## Scope

### In Scope
- **Secure Camera UI**: Custom camera screen with no gallery access
- **Anti-Spoofing**: Mock location detection on Android
- **Watermarking**: Overlay GPS + Timestamp + User ID on captured images
- **Edge Hashing**: SHA-256 hash generation on-device immediately after capture
- **Feature scaffolding**: Create `features/camera` and `features/hashing` directories

### Out of Scope
- Offline storage queue (Phase 3: Sync & Dashboard)
- Server-side hash verification
- On-chain transaction recording
- Admin dashboard

## Success Criteria
1. Camera screen opens without any gallery picker option
2. Mock location is detected and camera is disabled when GPS spoofing is active (Android)
3. Captured images contain visible watermark with coordinates, timestamp, and user ID
4. A SHA-256 hash is generated for each capture using the specified input format
5. All logic is unit tested

## Dependencies
- Phase 1 (Setup & Auth) must be complete ✓
- New packages required: `camera`, `geolocator`, `image`, `path_provider`

## Related Documents
- PRD: Section 3.2 (Secure Camera) and Section 3.3 (Cryptographic Proof)
- Phase 1 Design: `openspec/changes/phase-1-setup-auth/design.md`
