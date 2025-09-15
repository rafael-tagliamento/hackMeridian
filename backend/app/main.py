from fastapi import FastAPI
from .api.routers import vaccine

app = FastAPI(
    title="Vaccine Verification API",
    description="A robust and scalable backend for issuing and verifying vaccination tokens on the Stellar blockchain.",
    version="1.0.0",
)

# Include the router for vaccine-related endpoints
app.include_router(vaccine.router, prefix="/api/v1", tags=["Vaccine"])

@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint to welcome users to the API.
    """
    return {"message": "Welcome to the Vaccine Verification API. Visit /docs for documentation."}
