# Individual Formative 2

This repository contains the submission for **Individual Formative Assessment 2**.

## Project: resto_kigali

A Flutter mobile application for discovering and managing restaurant listings in Kigali, Rwanda.

| Detail | Value |
|--------|-------|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth + Cloud Firestore) |
| State Management | Provider (ChangeNotifier) |
| Maps | flutter_map + OpenStreetMap |

### Core Features

- **Authentication** — Email/password sign-up and login with Firebase Auth; email verification enforced before access
- **Restaurant Listings** — Browse, create, edit, and delete listings stored in Cloud Firestore
- **Search & Filter** — Search by name/category and filter by category chips
- **Map View** — Interactive map showing all listings with tap-to-detail markers
- **Bookmarks** — Save favourite listings per user account
- **Reviews & Ratings** — Submit star ratings and comments; average rating auto-calculated

### Known Bugs (Intentional — for Assessment)

| # | File | Bug |
|---|------|-----|
| 1 | `resto_kigali/pubspec.yaml` | `cloud_firestore: 4.17.5` conflicts with `firebase_core: ^4.5.0` — `flutter pub get` fails |
| 2 | `resto_kigali/lib/main.dart` | Missing `await` on `Firebase.initializeApp()` — app crashes on launch |

## Repository Structure

```
individual-formative2/
└── resto_kigali/          # Flutter application
    ├── lib/
    │   ├── main.dart
    │   ├── firebase_options.dart
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   ├── services/
    │   └── utils/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

See [`resto_kigali/README.md`](resto_kigali/README.md) for full setup instructions, Firestore schema, and project structure.

## Getting Started

```bash
cd resto_kigali
flutter pub get
flutter run
```

### Prerequisites

- Flutter SDK 3.x+
- Firebase project with Authentication (Email/Password) and Cloud Firestore enabled
- `google-services.json` placed in `resto_kigali/android/app/`
