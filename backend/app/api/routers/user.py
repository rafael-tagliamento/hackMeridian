from fastapi import APIRouter, HTTPException
from ...models.user_kyc import UserKYCCreate, UserKYCOut
from ...services import user_service

router = APIRouter()


@router.post("/users/register", response_model=UserKYCOut)
async def register_user(data: UserKYCCreate):
    try:
        return user_service.register_user_kyc(data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/users/{wallet_address}", response_model=UserKYCOut)
async def get_user(wallet_address: str):
    result = user_service.get_user_by_wallet(wallet_address)
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return result
