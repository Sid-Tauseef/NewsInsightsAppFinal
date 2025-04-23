from fastapi import APIRouter, HTTPException
from app.controller.recommend_controller import RecommendController
from app.services.recommend_service import RecommendationService
import logging
from pydantic import BaseModel
from typing import List

logger = logging.getLogger(__name__)

router = APIRouter()
service = RecommendationService()
controller = RecommendController(service)

class ArticleSchema(BaseModel):
    title: str
    category: str = "general"

class RecommendationRequest(BaseModel):
    liked_articles: List[ArticleSchema]

@router.post("/recommend")
async def get_recommendations(request: RecommendationRequest):
    logger.debug(f"Received recommendation request: {request.dict()}")
    articles = [article.dict() for article in request.liked_articles]
    recent_articles = list(reversed(articles))[:10]  # Take 10 newest
    logger.debug(f"Passing {len(recent_articles)} most recent articles: {[art['title'] for art in recent_articles]}")
    return await controller.recommend_articles(recent_articles)