# GezAI Backend

FastAPI backend for the GezAI travel route planning app.

## Setup

### Prerequisites
- Python 3.13+
- [uv](https://github.com/astral-sh/uv) package manager

### Installation

```bash
# Install dependencies
uv sync

# Copy environment variables
cp .env.example .env
# Edit .env with your actual values
```

### Running

```bash
# Development server with hot reload
uv run uvicorn app.main:app --reload

# Production
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000
```

API documentation: http://localhost:8000/docs

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GOOGLE_PLACES_API_KEY` | Google Places API key |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_CREDENTIALS_PATH` | Path to Firebase service account JSON |
| `GOOGLE_CACHE_DAYS` | Days before place data is considered stale (default: 30) |

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app entry point
│   ├── api/                  # Route handlers
│   │   ├── places.py         # Places CRUD
│   │   └── map_link.py       # Google Maps deep link generation
│   ├── core/
│   │   ├── config.py         # Settings from environment
│   │   ├── firebase.py       # Firebase Admin SDK singleton
│   │   └── auth.py           # Authentication middleware
│   ├── schemas/              # Pydantic request/response models
│   ├── services/             # External API integrations
│   └── repository/           # Firestore data access layer
├── pyproject.toml
├── requirements.txt
└── .env
```

## Deployment

The backend is designed to run on Google Cloud Run.

```bash
# Build container
docker build -t gezai-api .

# Deploy to Cloud Run
gcloud run deploy gezai-api --image gezai-api --region us-central1
```
