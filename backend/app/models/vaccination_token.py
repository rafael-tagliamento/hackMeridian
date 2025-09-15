from pydantic import BaseModel, Field, field_validator
from datetime import datetime

class VaccinationToken(BaseModel):
    id: int
    name: str = Field(..., min_length=2, max_length=64)
    description: str = Field(..., min_length=16, max_length=512)
    