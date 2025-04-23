# app/controller/user_controller.py
from datetime import timedelta
from fastapi import HTTPException, status
from app.services.user_services import UserServices
from app.utils.auth import generate_token  # Add this import
import bcrypt  # Ensure bcrypt is also imported


class UserController:
    @staticmethod
    async def register(request):
        try:
            # Extract fields from the request
            email = request.get("email")
            password = request.get("password")
            username = request.get("username")
            phone = request.get("phone")

            # Validate required fields
            if not all([email, password, username, phone]):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="All fields (email, password, username, phone) are required."
                )

            # ⚠️ DELEGATE TO SERVICE LAYER (NO REDUNDANT CHECKS) ⚠️
            return await UserServices.register_user(email, password, username, phone)

        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal server error"
            )
        
    @staticmethod
    async def login(email: str, password: str):  # Accept email/password as parameters
        try:
            # Validate parameters
            if not email or not password:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email and password are required."
                )

            # Find user and verify credentials
            user = await UserServices.find_user_by_email(email)
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User does not exist."
                )

            # Verify password
            is_valid = bcrypt.checkpw(password.encode(), user["password"])
            if not is_valid:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid credentials."
                )

            # Generate token
            token_data = {"_id": str(user["_id"]), "email": user["email"]}
            token = generate_token(token_data, expires_delta=timedelta(hours=1))


            return {"status": True, "message": "Login successful", "token": token}

        except HTTPException as e:
            raise e
        except Exception as e:
            print(f"Unexpected error during login: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal server error."
            )

    @staticmethod
    async def like_article(email: str, article_title: str, article_category: str):  # Accept 3 parameters
        try:
            await UserServices.like_article(email, article_title, article_category)
            return {"status": True, "message": "Article liked successfully"}
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal server error"
            )

    @staticmethod
    async def unlike_article(email: str, article_title: str):  # Accept 2 parameters
        try:
            await UserServices.unlike_article(email, article_title)
            return {"status": True, "message": "Article unliked successfully"}
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal server error"
            )

    @staticmethod
    async def get_user_details(email: str):  # Receive email directly as a string
        try:
            # Get user details
            user_details = await UserServices.get_user_details(email)
            return {"status": True, "data": user_details}
        except HTTPException as e:
            raise e
        except Exception as e:
            print("---> err -->", e)
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail="Internal server error")


    @staticmethod
    async def get_liked_articles(email: str):
        try:
            # Directly return the list from services
            return await UserServices.get_liked_articles(email)
        except HTTPException as e:
            # Propagate the error properly
            raise e
        except Exception as e:
            print(f"Controller error: {e}")
            raise HTTPException(status_code=500, detail="Internal server error")