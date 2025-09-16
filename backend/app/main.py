from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.routers import vaccine
from .api.routers import user  # novo router
from .services import database_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    database_service.create_tables()
    yield
    # Shutdown (add cleanup logic here if needed)


app = FastAPI(
    title="Vaccine Verification API",
    description="A robust and scalable backend for issuing and verifying vaccination tokens on the Stellar blockchain.",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Routers
app.include_router(vaccine.router, prefix="/api/v1", tags=["Vaccine"])
app.include_router(user.router, prefix="/api/v1", tags=["Users"])


@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint to welcome users to the API.
    """
    return {
        "message": "Welcome to the Vaccine Verification API. Visit /docs for documentation."
    }
