from pydantic import BaseModel, Field
from datetime import datetime


class VaccinationTokenBase(BaseModel):
    name: str = Field(
        ..., min_length=2, max_length=64, description="Name of the vaccine"
    )
    description: str = Field(
        ..., min_length=16, max_length=512, description="Description of the vaccine"
    )
    batch: str = Field(
        ..., min_length=2, max_length=64, description="Batch number of the vaccine"
    )
    taken_date: datetime = Field(..., description="Date when the vaccine was taken")
    expiration_date: datetime = Field(..., description="Date when the vaccine expires")



class VaccinationToken(VaccinationTokenBase):
    id: int = Field(..., description="Unique identifier for the vaccination token")

    class Config:
        from_attributes = True
