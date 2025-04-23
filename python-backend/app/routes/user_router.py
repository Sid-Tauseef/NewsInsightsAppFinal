# app/routes/user_router.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from app.controller.user_controller import UserController
from fastapi import APIRouter, HTTPException, Request  # Add Request here

router = APIRouter()

# Pydantic models for request validation
class RegisterRequest(BaseModel):
    email: str
    password: str
    username: str
    phone: str

class LoginRequest(BaseModel):
    email: str
    password: str

class LikeArticleRequest(BaseModel):
    email: str
    articleTitle: str
    articleCategory: str

class UnlikeArticleRequest(BaseModel):
    email: str
    articleTitle: str

class GetUserDetailsRequest(BaseModel):
    email: str

class GetLikedArticlesRequest(BaseModel):
    email: str


@router.post("/registration")
async def register(request: RegisterRequest):
    try:
        # Convert Pydantic model to dictionary
        request_data = request.dict()
        return await UserController.register(request_data)
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Unexpected error during registration: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/login")
async def login(request: Request):
    try:
        data = await request.json()
        email = data.get("email")
        password = data.get("password")
        
        if not email or not password:
            raise HTTPException(
                status_code=400,
                detail="Email and password are required"
            )
            
        return await UserController.login(email, password)
        
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Unexpected error during login: {e}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error"
        )

@router.post("/likeArticle")
async def like_article(request: LikeArticleRequest):
    try:
        await UserController.like_article(
            request.email,  # Pass 3 arguments
            request.articleTitle,
            request.articleCategory
        )
        return {"status": True, "message": "Article liked successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Unexpected error while liking article: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/unlikeArticle")
async def unlike_article(request: UnlikeArticleRequest):
    try:
        await UserController.unlike_article(
            request.email,  # Pass email
            request.articleTitle  # Pass article title
        )
        return {"status": True, "message": "Article unliked successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Unexpected error while unliking article: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/getUserDetails")
async def get_user_details(request: GetUserDetailsRequest):
    try:
        # Pass the email string directly to the controller
        return await UserController.get_user_details(request.email)
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Unexpected error while fetching user details: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    
# app/routes/user_router.py

@router.post("/getLikedArticles")
async def get_liked_articles(request: GetLikedArticlesRequest):
    try:
        print(f"\n📥 [REQUEST] Received getLikedArticles request for email: {request.email}")
        
        # Get raw array from controller
        liked_articles = await UserController.get_liked_articles(request.email)
        
        print(f"📤 [RESPONSE] Sending {len(liked_articles)} liked articles back to client")
        
        return {
            "status": True,
            "data": {
                "likedArticles": liked_articles
            }
        }
    except HTTPException as e:
        print(f"⚠️ [ERROR] HTTPException: {e.detail}")
        return {
            "status": False,
            "error": e.detail,
            "data": {"likedArticles": []}
        }
    except Exception as e:
        print(f"🔥 [CRITICAL] Unexpected error: {str(e)}")
        return {
            "status": False,
            "error": "Internal server error",
            "data": {"likedArticles": []}
        }