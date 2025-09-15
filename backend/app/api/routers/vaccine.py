from fastapi import APIRouter, Depends
from ...services import stellar_service
from ...models import vacination_token

router = APIRouter()


@router.post("/create_token")
async def create_token(token_data: vacination_token.VaccinationToken):
    """
    Receives vaccination data, validates it, and calls the service to create a token.
    """
    # The route validates the input data using the Pydantic model
    # Then, it calls the appropriate service function
    result = stellar_service.create_vac_token(token_data)
    return result


@router.get("/verify_vaccine/{asset_code}/{issuer_account}")
async def verify_vaccine(asset_code: str, issuer_account: str):
    """
    Verifies a vaccine token on the Stellar blockchain.
    """
    is_valid = stellar_service.verify_token_on_chain(asset_code, issuer_account)
    return {"is_valid": is_valid}
