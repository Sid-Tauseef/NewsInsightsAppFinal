# app/services/user_services.py
from app.models.user_model import UserModel
from datetime import timedelta
from app.utils.auth import generate_token
from fastapi import HTTPException
import bcrypt
from bson import ObjectId
from fastapi.encoders import jsonable_encoder

# app/services/user_services.py
class UserServices:
    # @staticmethod
    # async def register_user(email, password, username, phone):
    #     try:
    #         # Check for duplicates
    #         existing_email = await UserModel.find_user_by_email(email)
    #         existing_username = await UserModel.find_user_by_username(username)
    #         existing_phone = await UserModel.find_user_by_phone(phone)


    #         if existing_email:
    #             raise HTTPException(status_code=400, detail="Email already registered")
    #         if existing_username:
    #             raise HTTPException(status_code=400, detail="Username already taken")
    #         if existing_phone:
    #             raise HTTPException(status_code=400, detail="Phone number already registered")

    #         # ACTUALLY CREATE THE USER (THIS WAS MISSING)
    #         await UserModel.create_user(email, password, username, phone)
            
    #         return {"status": True, "message": "User registered successfully"}

    #     except HTTPException as e:
    #         raise e
    #     except Exception as e:
    #         print("---> err -->", e)
    #         raise HTTPException(status_code=500, detail="Internal server error")    

    @staticmethod
    async def register_user(email, password, username, phone):
        try:
            # Check for duplicates
            existing_email = await UserModel.find_user_by_email(email)
            existing_username = await UserModel.find_user_by_username(username)
            existing_phone = await UserModel.find_user_by_phone(phone)

            if existing_email is not None:
                raise HTTPException(status_code=400, detail="Email already registered")
            if existing_username is not None:
                raise HTTPException(status_code=400, detail="Username already taken")
            if existing_phone is not None:
                raise HTTPException(status_code=400, detail="Phone number already registered")

            await UserModel.create_user(email, password, username, phone)
            return {"status": True, "message": "User registered successfully"}

        except HTTPException as e:
            raise e
        except Exception as e:
            print("Registration error:", e)
            raise HTTPException(status_code=500, detail="Internal server error")
        
    @staticmethod
    async def find_user_by_email(email):
        try:
            return await UserModel.find_user_by_email(email)
        except Exception as e:
            print(f"Error finding user by email: {e}")
            raise HTTPException(status_code=500, detail="Database error")

    @staticmethod
    async def find_user_by_username(username):
        try:
            return await UserModel.find_user_by_username(username)
        except Exception as e:
            print(f"Error finding user by username: {e}")
            raise HTTPException(status_code=500, detail="Database error")

    @staticmethod
    async def find_user_by_phone(phone):
        try:
            return await UserModel.find_user_by_phone(phone)
        except Exception as e:
            print(f"Error finding user by phone: {e}")
            raise HTTPException(status_code=500, detail="Database error")

    @staticmethod
    async def login_user(email, password):
        try:
            # Find the user by email
            user = await UserModel.find_user_by_email(email)
            if not user:
                raise HTTPException(status_code=404, detail="User does not exist")

            # Verify the password
            is_password_correct = bcrypt.checkpw(password.encode(), user["password"])
            if not is_password_correct:
                raise HTTPException(status_code=401, detail="Invalid credentials")

            # Generate JWT token
            token_data = {"email": user["email"]}
            token = generate_token(token_data, expires_delta=timedelta(hours=1))
            return token

        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(status_code=500, detail="Internal server error")

    @staticmethod
    async def like_article(email: str, article_title: str, article_category: str):
        try:
            # Delegate to UserModel.like_article (uses $push)
            return await UserModel.like_article(email, article_title, article_category)
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(status_code=500, detail="Internal server error")

    @staticmethod
    async def unlike_article(email: str, article_title: str):
        try:
            return await UserModel.unlike_article(email, article_title)
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(status_code=500, detail="Internal server error")


    @staticmethod
    async def get_user_details(email: str):
        try:
            user = await UserModel.find_user_by_email(email)
            if not user:
                raise HTTPException(status_code=404, detail="User not found")

            # Convert MongoDB document to dict and remove password
            user_details = dict(user)  # Explicit conversion to dictionary
            user_details.pop("password", None)
            user_details.pop("_id", None)  # Remove MongoDB ObjectId
            
            return user_details
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(status_code=500, detail="Internal server error")

    @staticmethod
    async def get_liked_articles(email: str):
        try:
            print(f"\n🔍 [DEBUG] Fetching liked articles for email: {email}")
            
            user = await UserModel.find_user_by_email(email)
            if not user:
                print(f"⚠️ [WARN] User not found for email: {email}")
                return []
                
            liked_articles = user.get("likedArticles", [])
            print(f"✅ [SUCCESS] Found {len(liked_articles)} liked articles for {email}:")
            for idx, article in enumerate(liked_articles, 1):
                print(f"   {idx}. {article.get('title')} ({article.get('category')})")
                
            return liked_articles
            
        except Exception as e:
            print(f"🔥 [ERROR] Failed to get liked articles: {str(e)}")
            return []