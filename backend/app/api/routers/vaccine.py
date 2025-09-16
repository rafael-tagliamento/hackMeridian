from fastapi import APIRouter, Depends
from ...services import stellar_service
from ...models import vaccination_token
import logging
router = APIRouter()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)



@router.post("/apply_vaccine/{destination_key}")
async def apply_vaccine(
    destination_key: str,
    token_data: vaccination_token.VaccinationTokenBase
):
    """
    Receives vaccination data, validates it, and calls the service to create a token.
    """


    result = stellar_service.create_vac_token(token_data, destination_key)
    return result


# @router.get("/verify_vaccine/{asset_code}/{issuer_account}")
# async def verify_vaccine(asset_code: str, issuer_account: str):
#     """
#     Verifies a vaccine token on the Stellar blockchain.
#     """
#     is_valid = stellar_service.verify_token_on_chain(asset_code, issuer_account)
#     return {"is_valid": is_valid}
