# app/utils/auth.py
import jwt
from datetime import datetime, timedelta
from fastapi import HTTPException

# Secret key for signing and verifying tokens (replace with your actual secret)
JWT_SECRET = "0a43376a52f64439ab95ca607fa4ed27ad3118e8e6c408f49c0554e621323aa3"

def generate_token(data: dict, expires_delta: timedelta = None):
    """
    Generate a JWT token with the given data.
    :param data: Dictionary containing payload data (e.g., user ID, email).
    :param expires_delta: Optional expiration time for the token.
    :return: Encoded JWT token as a string.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=1)  # Default expiration: 1 hour
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET, algorithm="HS256")
    return encoded_jwt


def verify_token(token: str):
    """
    Verify and decode a JWT token.
    :param token: The JWT token to verify.
    :return: Decoded payload if the token is valid.
    :raises HTTPException: If the token is invalid or expired.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")