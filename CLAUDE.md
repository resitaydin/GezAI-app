# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GezAI** is an AI-powered travel planning mobile app that generates personalized walking/driving routes for Turkish cities (starting with Üsküdar district in Istanbul). This is a **monorepo** containing both the Flutter mobile app and FastAPI backend.

**Tech Stack:**
- **Flutter mobile app** (`app/`) - cross-platform UI with Riverpod state management
- **FastAPI backend** (`backend/`) - route generation, places sync, Google Maps deep links (Cloud Run)
- **Firebase** - Auth, Firestore for persistence
- **Gemini 2.5 Flash Lite** - LLM for processing user intent and generating route JSON
- **Google Places API (New)** - real-time place metadata, ratings, photos
- **Google Maps SDK** - map rendering and navigation export

## Repository Structure

```
GezAI/
├── app/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── config/         # App config, routes, constants
│   │   ├── models/         # Data models
│   │   ├── services/       # API and Firebase services
│   │   ├── providers/      # Riverpod state providers
│   │   ├── screens/        # App screens by feature
│   │   ├── widgets/        # Reusable UI components
│   │   └── utils/          # Helpers and extensions
│   └── assets/
│
├── backend/                # FastAPI Backend
│   ├── app/
│   │   ├── api/            # FastAPI routers
│   │   ├── core/           # Config, Firebase, auth
│   │   ├── schemas/        # Pydantic models
│   │   ├── services/       # External API integrations
│   │   └── repository/     # Firestore data access
│   ├── pyproject.toml
│   └── .env
│
├── docs/                   # Shared documentation
├── firebase.json           # Firebase project config
├── firestore.rules         # Security rules
└── firestore.indexes.json  # Firestore indexes
```

## Development Commands

### Backend (FastAPI)

```bash
cd backend

# Install dependencies (uses uv package manager)
uv sync

# Run development server
uv run uvicorn app.main:app --reload
```

API docs: http://localhost:8000/docs

### Frontend (Flutter)

```bash
cd app

# Initialize Flutter (first time only)
flutter create . --org com.gezai --project-name gez_ai

# Install dependencies
flutter pub get

# Run app
flutter run

# Configure Firebase
flutterfire configure
```

### Firebase

```bash
# Deploy Firestore rules (from root)
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

## Backend Architecture

### Key Patterns

**Firebase Singleton** (`backend/app/core/firebase.py`): Single `Firebase` class manages Firestore client and auth. Initialized at app startup. Collections: `firebase.places`, `firebase.routes`, `firebase.saved_routes`, `firebase.users`.

**Place Creation Flow** (`backend/app/api/places.py`):
1. Check Firestore by name+region
2. If not found, check by Google Place ID
3. If still not found, fetch from Google Places API (New)
4. Cache in Firestore with sync timestamps
5. Uses Google Place ID as Firestore document ID

**Caching Strategy**: Places cached with `google_last_synced_at` timestamp. Staleness threshold: `GOOGLE_CACHE_DAYS` (default 30 days). Sync status: `fresh | stale | error`.

### Services
- `GooglePlacesService`: Google Places API (New) - text search, place details, photo URLs
- `GoogleMapsLinkService`: Deep links for route navigation (walking, driving, transit)

### Backend Environment Variables

Create `backend/.env`:
```
GOOGLE_PLACES_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_CREDENTIALS_PATH=../firebase-credentials.json
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/places/` | Create or retrieve place by name and region |
| GET | `/api/v1/places/{place_id}` | Get place by ID |
| GET | `/api/v1/places/{place_id}/photos` | Get place photos |
| POST | `/api/v1/map_link/google-maps-link` | Generate Google Maps route URL (2-10 places) |
| GET | `/health` | Health check |

### Planned Endpoints
- `POST /api/v1/routes/generate` - LLM route generation
- `GET /api/v1/routes/{route_id}/navigation` - Google Maps deep link for saved route

## Firebase Collections

| Collection | Purpose |
|------------|---------|
| `users` | User profiles (Firebase Auth UID as document ID) |
| `routes` | Generated routes with embedded places array |
| `places` | Cached place data from Google Places |
| `saved_routes` | User's saved/bookmarked routes |

## MVP Constraints

- **Geofence**: Routes restricted to Üsküdar District
- **Transport Modes**: Walking, Personal Car, Public Transit (no ferry schedules)
- **Place Database**: Seed list of top 100 POIs in Üsküdar to minimize LLM hallucinations
- **Categories**: mosque, museum, park, restaurant, cafe, attraction, historical, poi, other

## Route Generation Data Flow

```
Flutter App
    │
    ▼
POST /api/v1/routes/generate
    │
    ├── LLM Service (Gemini)
    │       ▼
    │   Generate route structure
    │
    ├── Places Service (Google Places)
    │       ▼
    │   Resolve place names → place_ids
    │
    ├── Route Service
    │       ▼
    │   Save to Firestore
    │
    ▼
Response → Flutter App
```

## Implementation Status

### Backend ✅
- **Places API** - Full CRUD with Google Places sync
- **Google Maps Links** - Route deep link generation
- **Firebase Integration** - Auth + Firestore ready
- **Caching** - Smart place caching with staleness detection

### Frontend ✅
- **Authentication Flow** - Complete implementation
  - Sign in (email/password)
  - Sign up with email verification
  - Google Sign-In (OAuth 2.0)
  - Forgot password / Reset password
  - Email verification screen
- **State Management** - Riverpod providers for auth
- **Navigation** - GoRouter with auth guards
- **UI Components** - Reusable auth widgets

### Testing Infrastructure ✅
- **116 Total Tests**
  - 43 Unit Tests (100% passing)
  - 73 Widget Tests (40% passing - NetworkImage issues)
- **Test Coverage**
  - AuthService: 18 tests
  - AuthProvider: 25 tests
  - UI Screens: 73 tests
- **Mock Infrastructure** - Firebase Auth, Google Sign-In mocks
- **See** `app/test/README.md` for details

### Pending 🚧
- LLM route generation endpoint
- Route history/saved routes
- Home screen + map integration
- Fix widget tests (NetworkImage mocking)

## Flutter Authentication

### Architecture
**Service Layer** (`app/lib/services/auth_service.dart`):
- Firebase Auth singleton
- Google Sign-In integration
- Custom exception handling with user-friendly error messages
- Email verification and password reset flows

**State Management** (`app/lib/providers/auth_provider.dart`):
- `authServiceProvider` - AuthService singleton
- `authStateProvider` - Firebase auth state stream
- `authStatusProvider` - Routing decision logic (handles email verification)
- `authControllerProvider` - Auth operations (sign in/up/out)

**Auth Screens** (`app/lib/screens/auth/`):
- LoginScreen - Email/password + Google Sign-In
- SignupScreen - Registration with password strength indicator
- ForgotPasswordScreen - Password reset initiation
- PasswordResetSentScreen - Confirmation screen
- ResetPasswordScreen - Password reset with validation
- VerifyEmailScreen - Email verification with polling + resend

**Key Features**:
- Password strength visualization (4 levels)
- Email verification polling (checks every 3 seconds)
- Resend countdown (60s cooldown)
- Smart auth status (Google users bypass email verification)
- Form validation with real-time feedback

### Testing

```bash
# Run all unit tests (100% passing)
cd app && flutter test test/unit/

# Run all tests
cd app && flutter test

# Generate coverage report
cd app && flutter test --coverage

# Run specific test file
cd app && flutter test test/unit/services/auth_service_test.dart
```

**Test Structure**:
```
app/test/
├── helpers/           # Mocks and test utilities
├── unit/              # 43 tests - AuthService, AuthProvider
└── widgets/           # 73 tests - All auth screens
```

**Known Issue**: LoginScreen/SignupScreen tests partially fail due to `Image.network()` in test environment. Solution: wrap tests with `mockNetworkImagesFor()` (see test/README.md).
