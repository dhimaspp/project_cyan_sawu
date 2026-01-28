# Lean Canvas — Project Cyan: Sawu Seagrass dMRV (PRD v2)

## Problem
- Field MRV evidence for blue carbon (photos/GPS/time) is easy to manipulate and hard to audit, reducing trust in carbon claims and incentives.
- Data collection happens in low-connectivity coastal areas, so online-first workflows fail in practice.
- Verification and incentives are fragmented; contributors (fishers/verifiers) aren’t rewarded transparently or quickly.

## Customer Segments
- Primary: Fishers / local field contributors collecting seagrass evidence in remote coastal areas.
- Secondary: Verifiers (NGOs, researchers, community coordinators) validating submitted reports.
- Tertiary: Blue carbon project operators / MRV teams needing reliable monitoring data.
- (Later) Auditors / registries / buyers who want public, tamper-evident evidence trails.

## Unique Value Proposition
A trustless, offline-first dMRV app that turns real-world seagrass evidence into verifiable digital records, with transparent verification and rewards—bridging coastal field reality with blockchain-grade integrity.

## Solution
- Secure capture (“Prover”): camera-only capture, anti-mock-location checks, watermarking, and on-device SHA-256 hashing.
- Offline-first + resilient sync: local Hive storage + queued background sync to Supabase (photo + metadata + `data_hash`).
- On-chain anchoring: store an immutable reference by submitting proof and saving the Solana tx signature (`on_chain_tx`) for auditability.
- Verification + incentives (Phase 2): structured verification logs + reward/payout flow tied to verified reports and reputation.

## Key Metrics
- Reports successfully created and synced: # of reports with `photo_url` + `data_hash`.
- Offline-to-sync reliability: % of offline reports that reach synced state; median time-to-sync once online.
- On-chain anchoring adoption: % of reports with `on_chain_tx` recorded.
- Verification throughput: # verified reports per week; time from submission → verification.
- Integrity/fraud signal: #/% rejected reports due to hash mismatch or integrity checks.

## Channels
- Pilot deployments via local partners (fisher communities/cooperatives) in Sawu / seagrass sites.
- Partnerships with NGOs/universities running monitoring programs and field verification.
- Direct outreach to blue carbon project operators who need MRV tooling.
- (Later) Open-source distribution + developer communities for SDK/reference app adoption.

## Unfair Advantage
- Built for real field conditions (offline-first, low-bandwidth) combined with tamper-evident cryptographic proof and public auditability.
- Can evolve into a reusable public-good evidence layer (auditable hashes + on-chain anchor reference).

## Cost Structure
- Engineering: Flutter mobile app, backend (Supabase), Solana anchoring/verification/payments integration.
- Infrastructure: Supabase storage/bandwidth; Solana RPC usage/fees; monitoring/logging.
- Operations: verifier operations, pilot coordination, training/onboarding, field testing.
- Compliance/risk: privacy handling for public evidence and dispute-resolution overhead.

## Revenue Streams
- B2B subscription/contract from project operators for campaign operations, dashboards, and verification workflows.
- Service fees for verification and reporting (per verified report / per campaign).
- (Later) Protocol fee / payout handling fee if incentives move on-chain at scale.
- (Later) White-label/enterprise deployments for other blue carbon sites.
