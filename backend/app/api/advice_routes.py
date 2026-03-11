from fastapi import APIRouter, HTTPException, status
from app.schemas.advice_routes import (
    AdviceRouteCreate,
    AdviceRouteResponse,
    AdviceRouteListResponse
)
from app.services.advice_routes_service import advice_routes_service
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/advice-routes", tags=["Advice Routes"])


@router.post(
    "/",
    response_model=AdviceRouteResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create advice route (Admin)"
)
async def create_advice_route(data: AdviceRouteCreate):
    """
    POST /advice-routes - Create Advice Route

    Admin endpoint to create a new advice route from an existing route.

    - **route_id**: ID of the route to create advice route from
    """
    try:
        result = await advice_routes_service.create_advice_route(data)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get(
    "/",
    response_model=AdviceRouteListResponse,
    summary="List all advice routes"
)
async def list_advice_routes():
    """
    GET /advice-routes - List All Advice Routes

    Returns all advice routes with summary info.
    """
    result = await advice_routes_service.list_advice_routes()
    return result


@router.get(
    "/{advice_route_id}",
    response_model=AdviceRouteResponse,
    summary="Get advice route by ID"
)
async def get_advice_route(advice_route_id: str):
    """
    GET /advice-routes/{advice_route_id} - Get Advice Route

    Returns full advice route details including route data.
    """
    try:
        result = await advice_routes_service.get_advice_route(advice_route_id)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )


@router.delete(
    "/{advice_route_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete advice route (Admin)"
)
async def delete_advice_route(advice_route_id: str):
    """
    DELETE /advice-routes/{advice_route_id} - Delete Advice Route

    Admin endpoint to delete an advice route.
    """
    try:
        await advice_routes_service.delete_advice_route(advice_route_id)
        return None
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
