from typing import List, Optional
from datetime import datetime, timezone
from app.core.firebase import firebase
from google.cloud.firestore_v1 import FieldFilter
import logging
import asyncio

logger = logging.getLogger(__name__)

class SavedRoutesRepository:

    COLLECTION = 'saved_routes'

    def __init__(self):
        self._collection = None

    @property
    def collection(self):
        """Lazy initialization - access Firebase only when first needed"""
        if self._collection is None:
            self._collection = firebase.saved_routes
        return self._collection

    async def create(self, user_id: str, saved_route_data: dict) -> dict:
        """Create a new saved route"""

        now = datetime.now(timezone.utc)

        doc_ref = self.collection.document()

        doc_data = {
            "saved_route_id": doc_ref.id,
            "user_id": user_id,
            **saved_route_data,
            "started_at": None,
            "completed_at": None,
            "user_rating": None,
            "user_review": None,
            "saved_at": now,
            "updated_at": now
        }

        await asyncio.to_thread(doc_ref.set, doc_data)
        logger.info(f"Created saved route: {doc_ref.id}")

        return doc_data

    async def get_by_id(self, saved_route_id: str) -> Optional[dict]:
        """Get a saved route by its ID"""
        doc_ref = self.collection.document(saved_route_id)
        doc = await asyncio.to_thread(doc_ref.get)

        if doc.exists:
            return doc.to_dict()
        else:
            logger.warning(f"Saved route not found: {saved_route_id}")
            return None

    async def get_by_id_and_user(
            self,
            user_id: str,
            saved_route_id: str
    ) -> Optional[dict]:
        """ Get a saved route by its ID and user ID"""
        saved = await self.get_by_id(saved_route_id)

        if saved and saved.get('user_id') == user_id:
            return saved
        else:
            logger.warning(f"Saved route not found for user {user_id}: {saved_route_id}")
            return None

    async def find_by_route_and_user(
            self,
            user_id: str,
            route_id: str
    ) -> Optional[dict]:
        """Check if user already saved this route"""

        query = (
            self.collection
            .where(filter=FieldFilter('user_id', '==', user_id))
            .where(filter=FieldFilter('route_id', '==', route_id))
            .limit(1)
        )
        docs = await asyncio.to_thread(lambda: list(query.stream()))
        for doc in docs:
            return doc.to_dict()
        return None

    async def list_by_user(
            self,
            user_id: str
    ) -> List[dict]:
        """List all saved routes for a user"""
        query = self.collection.where(
            filter=FieldFilter('user_id', '==', user_id)
        )
        docs = await asyncio.to_thread(lambda: list(query.stream()))

        saved_routes = [doc.to_dict() for doc in docs]

        logger.info(f"Listed {len(saved_routes)} saved routes for user {user_id}")
        return saved_routes

    async def update(
            self,
            saved_route_id: str,
            data: dict
    ) -> Optional[dict]:
        """Update saved route"""
        data["updated_at"] = datetime.now(timezone.utc)

        doc_ref = self.collection.document(saved_route_id)
        await asyncio.to_thread(doc_ref.update, data)

        return await self.get_by_id(saved_route_id)

    async def delete(self, saved_route_id: str) -> bool:
        """Delete saved route - ownership already verified by service layer"""
        doc_ref = self.collection.document(saved_route_id)
        await asyncio.to_thread(doc_ref.delete)
        return True


saved_routes_repository = SavedRoutesRepository()