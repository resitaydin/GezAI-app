# GezAI Technical Reference

## Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile)       │
└────────┬────────┘
         │
         ├─────────────────────┐
         │                     │
         ▼                     ▼
┌─────────────────┐   ┌──────────────────┐
│  Firebase Auth  │   │  FastAPI Backend │
│  (Client-side)  │   │  (Cloud Run)     │
└─────────────────┘   └────────┬─────────┘
         │                     │
         │                     ├─→ Google Places API
         │                     ├─→ Gemini LLM
         │                     │
         ▼                     ▼
┌──────────────────────────────┐
│     Cloud Firestore          │
└──────────────────────────────┘
```

**Responsibilities:**
- **Flutter**: UI, Firebase Auth, direct Firestore for saved_routes
- **Backend**: Places caching, LLM route generation, map links, token verification
- **Firebase**: Auth (client-side), Firestore with security rules

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/places/` | Create or get place by name + region |
| `GET` | `/api/v1/places/{place_id}` | Get place by ID |
| `GET` | `/api/v1/places/{place_id}/photos` | Get photos |
| `POST` | `/api/v1/routes/generate` | Generate route (LLM) |
| `POST` | `/api/v1/map_link/google-maps-link` | Navigation deep link |
| `GET` | `/health` | Health check |

### Example: Create Place

**Request:**
```json
POST /api/v1/places/
{
  "name": "Kız Kulesi",
  "region": "uskudar"
}
```

**Response:**
```json
{
  "place_id": "ChIJ...",
  "name": "Kız Kulesi",
  "location": { "lat": 41.0214, "lng": 29.0042 },
  "category": "attraction",
  "rating": 4.6
}
```

### Example: Generate Route

**Request:**
```json
POST /api/v1/routes/generate
{
  "prompt": "3 saatlik tarihi Üsküdar turu",
  "region": "uskudar",
  "transport_mode": "walking",
  "max_places": 5
}
```

### Example: Map Link

**Request:**
```json
POST /api/v1/map_link/google-maps-link
{
  "places": [
    { "place_id": "ChIJ...", "name": "Kız Kulesi", "lat": 41.0214, "lng": 29.0042 }
  ],
  "travel_mode": "walking"
}
```

---

## Authentication

**No auth endpoints in backend.** Firebase Auth handled client-side.

```
1. User signs in (Flutter + Firebase Auth SDK)
2. Firebase returns ID token
3. Flutter sends: Authorization: Bearer <token>
4. Backend verifies token (Firebase Admin SDK)
```

---

## Firestore Collections

### users
```json
{
  "uid": "string",
  "email": "string",
  "display_name": "string | null",
  "account_status": "active | suspended | deleted",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### places
```json
{
  "place_id": "string",
  "google_place_id": "string | null",
  "name": "string",
  "location": { "lat": "number", "lng": "number" },
  "formatted_address": "string",
  "region": "string",
  "city": "string",
  "category": "string",
  "rating": "number | null",
  "photos": [{ "photo_reference": "string", "url": "string", "width": "number", "height": "number" }],
  "google_sync_status": "fresh | stale | error",
  "created_at": "timestamp"
}
```

### routes
```json
{
  "route_id": "string",
  "user_id": "string",
  "title": "string",
  "description": "string",
  "region": ["string"],
  "duration_hours": "number",
  "transport_type": "walking | driving | transit",
  "places": [{
    "place_id": "string",
    "order": "number",
    "duration_minutes": "number",
    "notes": "string",
    "travel_to_next": { "distance_km": "number", "duration_minutes": "number" }
  }],
  "summary": { "total_places": "number", "total_transport_minutes": "number", "total_visit_minutes": "number" },
  "is_featured": "boolean",
  "created_at": "timestamp"
}
```

### saved_routes
```json
{
  "saved_route_id": "string",
  "user_id": "string",
  "route_id": "string",
  "custom_title": "string | null",
  "custom_notes": "string | null",
  "planned_date": "timestamp | null",
  "user_rating": "number | null",
  "saved_at": "timestamp"
}
```

---

## Data Flow

### Route Generation (Backend)
```
Flutter → POST /routes/generate → Gemini LLM → Google Places → Firestore → Response
```

### Direct Firestore (No Backend)
```
Flutter ←→ Firestore
  ├── saved_routes (user CRUD)
  ├── routes (read featured)
  └── places (read cached)
```

---

## Project Structure

```
GezAI/
├── app/                    # Flutter
│   └── lib/
│       ├── config/
│       ├── models/
│       ├── services/
│       ├── providers/
│       ├── screens/
│       └── widgets/
│
├── backend/                # FastAPI
│   └── app/
│       ├── api/
│       ├── core/
│       ├── schemas/
│       ├── services/
│       └── repository/
│
├── docs/
├── firebase.json
├── firestore.rules
└── firestore.indexes.json
```
