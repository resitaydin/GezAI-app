# GezAI Flutter App

AI-powered travel route planning mobile app for Istanbul.

## Setup

### Initialize Flutter Project

Run these commands from this directory (`app/`):

```bash
# Initialize Flutter (run once)
flutter create . --org com.gezai --project-name gez_ai

# Install dependencies
flutter pub get

# Configure Firebase (requires FlutterFire CLI)
flutterfire configure
```

### Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0

  # Google Maps
  google_maps_flutter: ^2.5.3

  # HTTP & API
  dio: ^5.4.0

  # Utils
  go_router: ^13.0.1
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── config/                # App configuration, routes, constants
├── models/                # Data models (User, Route, Place, SavedRoute)
├── services/              # API and Firebase services
├── providers/             # Riverpod state providers
├── screens/               # App screens organized by feature
├── widgets/               # Reusable UI components
└── utils/                 # Helper functions and extensions
```

## Running the App

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for release
flutter build apk --release
flutter build ios --release
```
