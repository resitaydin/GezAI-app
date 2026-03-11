from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.core.firebase import firebase
from app.core.config import settings
from app.api import places, map_link, saved_routes, routes, advice_routes
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ===== STARTUP =====
    logger.info("Starting GezAI API...")
    firebase.initialize()

    yield

    # ===== SHUTDOWN =====
    logger.info("Shutting down...")


app = FastAPI(
    title="GezAI API",
    description="AI-powered travel route planning for Istanbul",
    version="1.0.0",
    lifespan=lifespan
)

# CORS - restrict to configured origins only
if settings.cors_origins_list:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["*"],
    )

# Routers
app.include_router(places.router, prefix="/api/v1")
app.include_router(map_link.router, prefix="/api/v1")
app.include_router(saved_routes.router, prefix="/api/v1")
app.include_router(routes.router, prefix="/api/v1")
app.include_router(advice_routes.router, prefix="/api/v1")


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "Istanbul Route Planner API"
    }