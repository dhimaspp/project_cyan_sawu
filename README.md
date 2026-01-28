# PRD: Project Cyan (dMRV Mobile Client)

## Metadata
| Key | Value |
| :--- | :--- |
| **Project Name** | Project Cyan: Sawu Seagrass dMRV |
| **Version** | 1.0 (MVP - Grant Phase) |
| **Status** | Draft / Ready for Dev |
| **Platform** | Mobile (iOS & Android via Flutter) |
| **Backend** | Supabase (PostgreSQL, Auth, Storage) |
| **Web3 Integration** | Solana (Wallet Connect & Hashing) |
| **Owner** | [Nama Anda/Tim Anda] |

## 1. Executive Summary & Objective

### 1.1 Product Vision
Membangun infrastruktur Digital Monitoring, Reporting, and Verification (dMRV) yang terdesentralisasi untuk aset karbon biru (Lamun) di Indonesia. Aplikasi ini berfungsi sebagai "Point of Truth" yang menjembatani kondisi fisik lapangan dengan integritas data blockchain.

### 1.2 MVP Goals (Grant Scope)
1. **Trustless Data Collection**: Membuktikan bahwa data biomasa diambil di lokasi dan waktu yang sebenarnya tanpa manipulasi digital.
2. **Hybrid User Experience**: Memungkinkan adopsi massal oleh nelayan (Web2 Login) sambil tetap mempertahankan kompatibilitas Web3 (Wallet Connect).
3. **Connectivity Resilience**: Berfungsi penuh di area low-bandwidth (tengah laut) dengan mekanisme Offline-First.

## 2. Technical Architecture

### 2.1 High-Level Stack
- **Frontend**: Flutter (Dart) - Null Safety enabled.
- **State Management**: Riverpod (with Code Generation).
- **Backend**: Supabase (BaaS).
- **Auth**: Supabase Auth (Email/Social) + Solana Wallet Adapter (Link Identity).
- **Local Storage**: Hive (NoSQL key-value database) untuk caching data offline.
- **Map Rendering**: flutter_map (OpenStreetMap) untuk efisiensi biaya (Free Tier).
- **UI Framework**: Material 3 Design dengan kustomisasi tema (e.g., FlexColorScheme) untuk tampilan premium.
- **Architecture**: Feature-first folder structure. Repository Pattern (via GetIt) untuk abstraksi data layer.

### 2.2 Data Flow Diagram (Conceptual)
1. **Capture**: User memotret via App (Camera Stream Only).
2. **Sign**: App melakukan hashing SHA-256 (Image + Metadata) di perangkat (Client-side).
3. **Store (Local)**: Data disimpan di Hive jika offline.
4. **Sync**: Auto-sync ke Supabase DB & Storage saat online.
5. **Verify**: Verifikator/Smart Contract membandingkan Hash yang tersimpan dengan Hash gambar.

## 3. Detailed Feature Specifications

### 3.1 Authentication (Hybrid Identity)
- **Primary Login (Web2)**:
  - Email & Password atau Social Login (Google/Apple).
  - Tujuannya: Login standard yang mudah diadopsi.
- **Secondary Connect (Web3)**:
  - Menu: "Connect Wallet" (Settings Page).
  - Mekanisme: Deep Link ke Phantom/Solflare.
  - Action: User menandatangani pesan statis (Sign Message) untuk membuktikan kepemilikan wallet.
  - Logic: Public Key disimpan di tabel profiles dan di-link ke User ID.

### 3.2 Secure Camera (The "Prover" Module)
Fitur inti untuk mencegah pemalsuan data.
- **No Gallery Access**: Tombol upload dari galeri dinonaktifkan secara hardcode.
- **Anti-Spoofing**:
  - Cek `isMockLocation` (Android Developer Option detector).
  - Menggunakan `Geolocator.getCurrentPosition` dengan `desiredAccuracy: LocationAccuracy.best`.
- **Watermarking Overlay**:
  - Aplikasi merender teks di atas image byte buffer sebelum disimpan:
  - Format: `LAT, LONG | TIMESTAMP (UTC) | USER_ID`.

### 3.3 Cryptographic Proof (Edge Hashing)
Proses ini terjadi di background segera setelah tombol shutter ditekan.
- **Algorithm**: SHA-256.
- **Input String**:
  ```
  Plaintext[User_UUID] + [Unix_Timestamp_ms] + [Lat_Float] + [Long_Float] + [Base64_Image_String]
  ```
- **Output**: Hexadecimal String (e.g., `a1b2c3...`).
- **Function**: Hash ini dikirim ke server sebagai kolom `data_hash`.

### 3.4 Offline Mode Strategy
- **State Management**: Menggunakan Riverpod untuk memantau status koneksi.
- **Queue System**:
  - **Jika Offline**: Data masuk ke Queue (Hive Box `pending_uploads`).
  - **Jika Online**: Worker berjalan di background untuk mengupload item di Queue satu per satu.
- **Robustness (Retry Policy)**:
  - Maksimal 3x auto-retry dengan *exponential backoff* jika upload gagal.
  - Jika tetap gagal, user mendapat notifikasi "Action Required" untuk re-sync manual.
- **Failure Handling**:
  - Jika Hash Mismatch (server reject): Report ditandai `rejected` dan user mendapat notifikasi alasannya.

## 4. Database Schema (Supabase PostgreSQL)
Berikut adalah struktur tabel SQL yang siap di-deploy di SQL Editor Supabase.

### 4.1 Table: profiles (User Data)
```sql
create table public.profiles (
  id uuid references auth.users not null primary key,
  full_name text,
  email text,
  role text default 'verifier', -- 'verifier' or 'admin'
  wallet_address text unique, -- Solana Address
  reputation_score int default 0, -- Rules: +10 per Verified Report, -50 per Fraud/Rejected
  created_at timestamptz default now()
);

-- Enable RLS (Row Level Security)
alter table public.profiles enable row level security;
```

### 4.2 Table: campaigns (Lokasi Proyek)
```sql
create table public.campaigns (
  id uuid default gen_random_uuid() primary key,
  title text not null, -- e.g. "Zona A - Laut Sawu"
  description text,
  target_polygon jsonb, -- GeoJSON coordinates area
  status text default 'active',
  created_at timestamptz default now()
);
```

### 4.3 Table: field_reports (Data Karbon)
```sql
create table public.field_reports (
  id uuid default gen_random_uuid() primary key,
  campaign_id uuid references public.campaigns,
  user_id uuid references public.profiles not null,
  
  -- Core Data
  photo_url text not null, -- Supabase Storage Path
  gps_lat double precision not null,
  gps_long double precision not null,
  
  -- Verification Data
  captured_at timestamptz not null,
  device_info text, -- e.g. "Samsung A50 - Android 11"
  
  -- Web3 Proof
  data_hash text not null, -- SHA256 Hash generated on Client
  on_chain_tx text, -- Kosongkan dulu, diisi nanti oleh Admin
  
  -- Status
  status text default 'pending', -- pending, verified, rejected
  created_at timestamptz default now()
);
```

### 4.4 Storage Bucket
- **Bucket Name**: `evidence-photos`
- **Policy**:
  - **INSERT**: Authenticated users only.
  - **READ**: Public (Demi transparansi publik dan audit pihak ketiga).
  - *Note*: Metadata sensitif (No HP) tidak boleh di-embed dalam EXIF foto publik.

### 4.5 Row Level Security (RLS) Policies
- **Profiles**:
  - `SELECT`: Public (untuk Leaderboard/Transparency).
  - `UPDATE`: Own user only.
- **Field Reports**:
  - `INSERT`: Authenticated users only.
  - `SELECT`: Public (untuk peta sebaran).
  - `UPDATE`: Only 'admin' or 'verifier' role (untuk update status).

## 5. Security & Risk Mitigation

| Risiko | Mitigasi Teknis |
| :--- | :--- |
| **GPS Spoofing (Fake Location)** | Implementasi `flutter_geolocator` dengan pengecekan `isMockLocation`. Tolak input jika terdeteksi. |
| **Fake Photos (Upload gambar lama)** | Akses kamera eksklusif via `camera` package. Nonaktifkan Image Picker dari galeri. |
| **Man-in-the-Middle Attack** | Validasi Hash. Hash yang dihitung di client harus cocok dengan hash yang dihitung ulang oleh verifikator saat audit. |
| **Sybil Attack (Akun palsu)** | Login dibatasi via validasi Email. |

## 6. Implementation Roadmap (Grant Timeline)

### Phase 1: Setup & Auth (Week 1) ✅
- [ ] Setup Flutter Project & Supabase Project.
- [ ] Implementasi Login (Email/Social).
- [ ] Integrasi Phantom Deep Link (Get Wallet Address).

### Phase 2: The Core "Prover" (Week 2) ✅
- [ ] Build Custom Camera UI.
- [ ] Implementasi Watermarking Logic.
- [ ] Implementasi SHA-256 Hashing Logic.

### Phase 3: Sync & Dashboard (Week 3) ✅
- [ ] Setup Hive untuk Offline Storage.
- [ ] Build "Background Sync" mechanism.
- [ ] Buat dashboard admin sederhana (Web) untuk melihat peta sebaran foto.

### Phase 4: Testing & Demo (Week 4) 🔲
- [ ] Field Test (Simulasi lapangan).
- [ ] Record Video Demo untuk submission Grant (Tunjukkan flow: Foto Offline -> Online -> Sync -> Hash muncul di DB).

---

## 7. Current Implementation Status

*Last Updated: 2026-01-28*

### 7.1 Completed Features

#### ✅ Home Page (`lib/src/features/home/`)
Fully implemented main dashboard screen after authentication.

**UI Components:**
- Welcome header displaying current user email
- **Capture Report** button (primary FilledButton) - navigates to CameraPage
- **View Reports** button (secondary OutlinedButton) - navigates to ReportsPage
- Sign out action in AppBar with confirmation dialog

**Technical Details:**
- Built with `ConsumerWidget` using Riverpod
- Integrates with `AuthRepository` for logout functionality
- Clean Material 3 design with proper spacing and typography

---

#### ✅ Reports Page (`lib/src/features/reports/`)
Complete reports management system with offline-first architecture.

##### 7.1.1 Domain Layer (`domain/field_report.dart`)
**`FieldReport` Model:**
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Local UUID v4 identifier |
| `imageBytes` | `Uint8List` | Captured image with watermark |
| `latitude` | `double` | GPS latitude |
| `longitude` | `double` | GPS longitude |
| `capturedAt` | `DateTime` | UTC timestamp of capture |
| `userId` | `String` | Supabase user ID |
| `dataHash` | `String` | SHA-256 verification hash |
| `syncStatus` | `SyncStatus` | Current sync state |
| `remoteId` | `String?` | Supabase record ID (after sync) |
| `photoUrl` | `String?` | Supabase Storage URL (after sync) |
| `errorMessage` | `String?` | Sync failure reason |

**`SyncStatus` Enum:**
- `pending` - Saved locally, awaiting sync
- `syncing` - Currently uploading to Supabase
- `synced` - Successfully uploaded and recorded
- `failed` - Sync failed, requires retry

##### 7.1.2 Data Layer
**`LocalReportStorage` (`data/local_report_storage.dart`):**
- Hive-based NoSQL storage for offline persistence
- Box name: `field_reports`
- JSON serialization with Base64 image encoding
- Methods: `saveReport`, `getAllReports`, `updateReport`, `deleteReport`, `getReport`, `getPendingReports`
- Automatic sorting by capture date (newest first)
- User-scoped queries (filters by userId)

**`RemoteReportService` (`data/remote_report_service.dart`):**
- Supabase Storage integration for photo uploads
- Bucket: `evidence-photos`
- Path structure: `{userId}/{reportId}.jpg`
- Table: `field_reports` (matches PRD schema)
- Database fields: `user_id`, `photo_url`, `gps_lat`, `gps_long`, `captured_at`, `data_hash`, `status`

**`ReportRepository` (`data/report_repository.dart`):**
- Unified interface for local + remote operations
- **Offline-First Flow:**
  1. Generate UUID v4 for local ID
  2. Save to Hive with `pending` status
  3. Attempt sync (update to `syncing`)
  4. On success: update with `synced` status, `remoteId`, `photoUrl`
  5. On failure: update with `failed` status and error message
- Retry mechanism via `retrySyncReport(reportId)`
- Riverpod provider with dependency injection

##### 7.1.3 Presentation Layer (`presentation/reports_page.dart`)
**Main Page Features:**
- `ConsumerStatefulWidget` with manual state management
- Pull-to-refresh via `RefreshIndicator`
- Empty state with icon and helpful text
- Loading indicator during data fetch

**Report List Item:**
- Thumbnail preview (60x60px) from local image bytes
- Formatted date/time display
- GPS coordinates with N/S/E/W indicators
- Hash preview (first 12 characters + ellipsis)
- Visual sync status indicators:
  - ✅ Green cloud icon for synced
  - 🕐 Orange upload icon for pending
  - 🔄 CircularProgressIndicator for syncing
  - ❌ Red error icon with retry button for failed

**Report Detail Bottom Sheet:**
- Draggable scrollable sheet (50-95% height)
- Full-size photo preview
- Complete metadata display:
  - Captured date/time
  - GPS location
  - Sync status
  - Full SHA-256 hash (monospace font)
  - Remote ID (if synced)
  - Error message (if failed, in red)

---

### 7.2 Implementation Progress Summary

| Phase | Status | Notes |
| :--- | :---: | :--- |
| Phase 1: Setup & Auth | ✅ Complete | Login, logout, Supabase integration |
| Phase 2: Core "Prover" | ✅ Complete | Camera, watermarking, SHA-256 hashing |
| Phase 3: Sync & Dashboard | ✅ Complete | Hive offline storage, Supabase sync, Reports page |
| Phase 4: Testing & Demo | 🔲 Pending | Field testing and video demo |

---

## 8. Dependencies (pubspec.yaml snippet)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Core Logic
  supabase_flutter: ^2.0.0
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  hive: ^2.2.3
  hive_flutter: ^1.1.0
  get_it: ^7.6.0 # DI
  
  # Device Features
  camera: ^0.10.5
  geolocator: ^10.1.0
  path_provider: ^2.1.1
  
  # Web3 & Crypto
  crypto: ^3.0.3
  url_launcher: ^6.2.0
  
  # UI
  google_fonts: ^6.1.0
  flutter_map: ^6.0.0 # OpenStreetMap
```

## 9. Proof of Work
- [View Proof of Work (Video/Docs)](https://drive.google.com/file/d/1qgqnGRR4csy6YwrtOuS5k3wC1bjanJt5/view?usp=sharing)
- [Download APK (Release)](https://drive.google.com/file/d/1QbPluhQ7b_YbGeorG4l8Kf-M68mvLMxR/view?usp=sharing)
