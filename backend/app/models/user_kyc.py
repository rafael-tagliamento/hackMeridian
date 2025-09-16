from pydantic import BaseModel, Field, field_validator
from datetime import datetime
import re

WALLET_REGEX = re.compile(r"^G[A-Z2-7]{55}$")  # Stellar public key pattern (56 chars)


class UserKYCBase(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=150)
    document_id: str = Field(..., min_length=3, max_length=80)
    id_photo_ref: str = Field(
        ..., description="Path, URL, IPFS hash or similar reference to the ID photo"
    )


class UserKYCCreate(UserKYCBase):
    wallet_address: str = Field(..., description="Stellar wallet public key (G...)")

    @field_validator("wallet_address")
    @classmethod
    def validate_wallet(cls, v: str):
        if not WALLET_REGEX.match(v):
            raise ValueError("Invalid Stellar wallet address format")
        return v

    @field_validator("document_id")
    @classmethod
    def normalize_doc(cls, v: str):
        return v.strip()


class UserKYCOut(UserKYCBase):
    id: int
    wallet_address: str
    created_at: datetime

    class Config:
        from_attributes = True
