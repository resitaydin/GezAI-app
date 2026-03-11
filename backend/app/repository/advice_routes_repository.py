from typing import List, Optional
from datetime import datetime, timezone
from app.core.firebase import firebase
from google.cloud.firestore_v1 import FieldFilter
import logging
import asyncio

logger = logging.getLogger(__name__)

class AdviceRoutesRepository:

    COLLECTION = 'advice_routes'

    def __init__(self):
        self._collection = None

    @property
    def collection(self):
        """Lazy initialization - access Firebase only when first needed"""
        if self._collection is None:
            self._collection = firebase.advice_routes
        return self._collection

    async def create(self, advice_route_data: dict) -> dict:
        """Create a new advice route"""

        now = datetime.now(timezone.utc)

        doc_ref = self.collection.document()

        doc_data = {
            "advice_route_id": doc_ref.id,
            **advice_route_data,
            "created_at": now,
            "updated_at": now
        }

        await asyncio.to_thread(doc_ref.set, doc_data)
        logger.info(f"Created advice route: {doc_ref.id}")

        return doc_data

    async def get_by_id(self, advice_route_id: str) -> Optional[dict]:
        """Get an advice route by its ID"""
        doc_ref = self.collection.document(advice_route_id)
        doc = await asyncio.to_thread(doc_ref.get)

        if doc.exists:
            return doc.to_dict()
        else:
            logger.warning(f"Advice route not found: {advice_route_id}")
            return None

    async def find_by_route(self, route_id: str) -> bool:
        """Find an advice route by its route ID"""
        query = self.collection.where(
            filter=FieldFilter("route_id", "==", route_id)
        ).limit(1)
        docs = await asyncio.to_thread(lambda: list(query.stream()))
        if docs:
            logger.info(f"Found existing advice route for route_id: {route_id}")
            return True
        logger.info(f"No existing advice route found for route_id: {route_id}")
        return False

    async def get_all_advice_routes(self) -> List[dict]:
        """Get all advice routes"""
        docs = await asyncio.to_thread(lambda: list(self.collection.stream()))
        advice_routes = [doc.to_dict() for doc in docs]
        logger.info(f"Retrieved {len(advice_routes)} advice routes")
        return advice_routes

    async def delete(self, advice_route_id: str) -> bool:
        """Delete an advice route by its ID"""
        doc_ref = self.collection.document(advice_route_id)
        await asyncio.to_thread(doc_ref.delete)
        logger.info(f"Deleted advice route: {advice_route_id}")
        return True

advice_routes_repository = AdviceRoutesRepository()