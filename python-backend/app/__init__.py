# app/__init__.py
from fastapi import FastAPI
from .config.db import db

app = FastAPI()

@app.on_event("startup")
async def startup():
    print("Connecting to MongoDB...")
    if db.command("ping"):
        print("MongoDB connected successfully.")

@app.on_event("shutdown")
async def shutdown():
    print("Closing MongoDB connection...")