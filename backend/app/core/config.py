from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache
from pathlib import Path
import logging
import os

logger = logging.getLogger(__name__)

# Get the path to backend/.env relative to this file
ENV_FILE = Path(__file__).resolve().parent.parent.parent / ".env"

# Whether to load secrets from Google Cloud Secret Manager
USE_SECRET_MANAGER = os.environ.get("USE_SECRET_MANAGER", "false").lower() == "true"


def _get_secret(secret_id: str, project_id: str) -> str:
    """Fetch a secret value from Google Cloud Secret Manager."""
    from google.cloud import secretmanager

    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")


def _load_secrets_from_sm(project_id: str) -> dict[str, str]:
    """Load all application secrets from Secret Manager."""
    secret_keys = [
        "GOOGLE_PLACES_API_KEY",
    ]
    secrets = {}
    for key in secret_keys:
        try:
            secrets[key] = _get_secret(key, project_id)
        except Exception as e:
            logger.warning("Failed to load secret %s: %s", key, e)
    return secrets


class Settings(BaseSettings):
    # Google Places API
    GOOGLE_PLACES_API_KEY: str = ""

    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CREDENTIALS_PATH: str = ""

    # Cache settings
    GOOGLE_CACHE_DAYS: int = 30  # Re-sync after 30 days

    # CORS - comma-separated allowed origins
    CORS_ORIGINS: str = ""

    model_config = SettingsConfigDict(
        env_file=ENV_FILE if ENV_FILE.exists() else None,
        extra='ignore'  # Ignore extra fields in .env
    )

    @property
    def cors_origins_list(self) -> list[str]:
        if not self.CORS_ORIGINS:
            return []
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]


@lru_cache()
def get_settings() -> Settings:
    s = Settings()

    if USE_SECRET_MANAGER and s.FIREBASE_PROJECT_ID:
        logger.info("Loading secrets from Secret Manager...")
        secrets = _load_secrets_from_sm(s.FIREBASE_PROJECT_ID)
        for key, value in secrets.items():
            setattr(s, key, value)

    return s

settings = get_settings()
