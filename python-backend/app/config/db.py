# app/config/db.py
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

load_dotenv()

client = None
db = None

async def connect_to_mongo():
    global client, db
    client = AsyncIOMotorClient(os.getenv("MONGO_URI"))
    db = client["test"]  # Replace "test" with your actual database name
    print("MongoDB connected successfully.")

async def close_mongo_connection():
    global client
    if client:
        client.close()
        print("MongoDB connection closed.")

def get_db():
    if db is None:
        raise ValueError("Database not initialized")
    return db