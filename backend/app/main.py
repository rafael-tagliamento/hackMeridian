from fastapi import FastAPI
from .api.routers import vaccine
from .api.routers import user  # novo router
from .services import database_service

app = FastAPI(
    title="Vaccine Verification API",
    description="A robust and scalable backend for issuing and verifying vaccination tokens on the Stellar blockchain.",
    version="1.0.0",
)

# Routers
app.include_router(vaccine.router, prefix="/api/v1", tags=["Vaccine"])
app.include_router(user.router, prefix="/api/v1", tags=["Users"])  


@app.on_event("startup")
def on_startup():
    database_service.create_tables()


@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint to welcome users to the API.
    """
    return {
        "message": "Welcome to the Vaccine Verification API. Visit /docs for documentation."
    }
