from fastapi import APIRouter, Request, status
from app.schemas.campaign import CampaignPlanRequest, CampaignPlanResponse
from app.services.campaign_service import CampaignService

router = APIRouter(prefix="/campaign", tags=["Campaign"])


@router.post(
    "/plan",
    response_model=CampaignPlanResponse,
    status_code=status.HTTP_200_OK,
    summary="Plan cohesive multi-day creator content campaign",
)
async def plan_campaign(
    request: Request,
    payload: CampaignPlanRequest,
) -> CampaignPlanResponse:
    """
    Accepts campaign objectives and creator context to generate a strategic
    multi-day content roadmap.
    """
    return await CampaignService.plan_campaign(payload)
