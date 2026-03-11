from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.saved_routes import (
    SavedRouteCreate,
    SavedRouteUpdate,
    SavedRouteResponse,
    SavedRouteListResponse
)
from app.services.saved_routes_service import saved_routes_service
from app.core.auth import get_current_user

router = APIRouter(prefix="/saved-routes",tags=["saved-routes"])

@router.post("/", response_model=SavedRouteResponse, status_code=status.HTTP_201_CREATED, summary="Save a route")
async def save_route(
    data: SavedRouteCreate,
    current_user: str = Depends(get_current_user)
) -> SavedRouteResponse:
    """Save a route for the current user"""
    try:
        return await saved_routes_service.save_route(current_user["user_id"], data)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/", response_model=SavedRouteListResponse, status_code=status.HTTP_200_OK)
async def list_saved_routes(
    current_user: str = Depends(get_current_user)
) -> SavedRouteListResponse:
    """List saved routes for the current user with pagination"""
    return await saved_routes_service.list_saved_routes(current_user["user_id"])


@router.get("/{saved_route_id}", response_model=SavedRouteResponse, summary="Get a saved route by ID")
async def get_saved_route(
    saved_route_id: str,
    current_user: str = Depends(get_current_user)
) -> SavedRouteResponse:
    """Get a saved route by ID for the current user"""
    try:
        return await saved_routes_service.get_saved_route(current_user["user_id"], saved_route_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

@router.put("/{saved_route_id}",response_model=SavedRouteResponse,summary="Update saved route")
async def update_route(
    saved_route_id: str,
    data: SavedRouteUpdate,
    current_user: dict = Depends(get_current_user)
):
    updated = await saved_routes_service.update_saved_route(
        current_user["user_id"], saved_route_id, data
    )
    if not updated:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Route not found")
    return updated

@router.delete("/{saved_route_id}",status_code=status.HTTP_204_NO_CONTENT,summary="Delete saved route")
async def delete_saved_route(
    saved_route_id: str,
    current_user: dict = Depends(get_current_user)
):
    deleted = await saved_routes_service.delete_saved_route(
        current_user["user_id"], saved_route_id
    )
    if not deleted:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Saved route not found")
    return None