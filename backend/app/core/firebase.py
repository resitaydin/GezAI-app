import firebase_admin
from firebase_admin import credentials, firestore, auth
from app.core.config import settings
from typing import Optional
from pathlib import Path
import logging
import os

logger = logging.getLogger(__name__)

# Resolve credentials path relative to backend/ directory
BACKEND_DIR = Path(__file__).resolve().parent.parent.parent


class Firebase:
    """
    Singleton Firebase manager for Istanbul Route Planner

    Usage:
        from core.firebase import firebase, get_db, get_collection

        # In main.py (startup)
        firebase.initialize()

        # In repositories
        collection = get_collection("places")
        db = get_db()
    """

    _instance: Optional['Firebase'] = None
    _initialized: bool = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if Firebase._initialized:
            return
        self._db = None
        self._auth = None

    def initialize(self):
        """Initialize Firebase Admin SDK - Call once at startup"""
        if Firebase._initialized:
            logger.info("Firebase already initialized")
            return

        try:
            if not firebase_admin._apps:
                cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

                if cred_path and Path(cred_path).exists():
                    # Local development with service account key
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred, {
                        'projectId': settings.FIREBASE_PROJECT_ID
                    })
                    logger.info("✅ Firebase initialized with credentials file")
                else:
                    # Cloud Run — auto-discovers credentials
                    firebase_admin.initialize_app(options={
                        'projectId': settings.FIREBASE_PROJECT_ID
                    })
                    logger.info("✅ Firebase initialized with default credentials")

            self._db = firestore.client()
            self._auth = auth
            Firebase._initialized = True

        except Exception as e:
            logger.error(f"❌ Firebase initialization failed: {e}")
            raise

    # ===== PROPERTIES =====

    @property
    def db(self) -> firestore.Client:
        """Get Firestore client"""
        if not Firebase._initialized:
            raise RuntimeError("Firebase not initialized. Call initialize() first.")
        return self._db

    @property
    def auth(self):
        """Get Firebase Auth module"""
        if not Firebase._initialized:
            raise RuntimeError("Firebase not initialized. Call initialize() first.")
        return self._auth

    # ===== COLLECTION HELPERS =====

    def get_collection(self, name: str):
        """Get Firestore collection reference"""
        return self.db.collection(name)

    # Collection shortcuts for this project
    @property
    def places(self):
        """Get places collection"""
        return self.get_collection("places")

    @property
    def routes(self):
        """Get routes collection"""
        return self.get_collection("routes")

    @property
    def saved_routes(self):
        """Get saved_routes collection"""
        return self.get_collection("saved_routes")

    @property
    def advice_routes(self):
        """Get advice_routes collection"""
        return self.get_collection("advice_routes")

    @property
    def users(self):
        """Get users collection"""
        return self.get_collection("users")

    # ===== AUTH HELPERS =====

    def verify_token(self, token: str) -> dict:
        """
        Verify Firebase ID token

        Returns:
            Decoded token dict with uid, email, etc.

        Raises:
            ValueError: If token is invalid or expired
        """
        try:
            return self._auth.verify_id_token(token)
        except self._auth.InvalidIdTokenError:
            raise ValueError("Invalid token")
        except self._auth.ExpiredIdTokenError:
            raise ValueError("Token expired")
        except Exception as e:
            raise ValueError(f"Token verification failed: {str(e)}")

    def get_user(self, uid: str):
        """Get Firebase user by UID"""
        return self._auth.get_user(uid)

    def get_user_by_email(self, email: str):
        """Get Firebase user by email"""
        return self._auth.get_user_by_email(email)


# ===== SINGLETON INSTANCE =====
firebase = Firebase()


# ===== CONVENIENCE FUNCTIONS =====

def get_db() -> firestore.Client:
    """Get Firestore database client"""
    return firebase.db


def get_auth():
    """Get Firebase Auth module"""
    return firebase.auth


def get_collection(name: str):
    """Get Firestore collection by name"""
    return firebase.get_collection(name)