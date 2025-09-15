from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from .database_service import get_session
from ..models.user_kyc_entity import UserKYC
from ..models.user_kyc import UserKYCCreate, UserKYCOut


def register_user_kyc(data: UserKYCCreate) -> UserKYCOut:
    """Registra um usuário KYC. Retorna UserKYCOut ou lança ValueError em caso de duplicidade."""
    with get_session() as session:  
        entity = UserKYC(
            wallet_address=data.wallet_address,
            full_name=data.full_name,
            document_id=data.document_id,
            id_photo_ref=data.id_photo_ref,
        )
        session.add(entity)
        try:
            session.flush()  # garante que ID é gerado
        except IntegrityError:
            raise ValueError("Wallet já registrada")
        return UserKYCOut.model_validate(entity)


def get_user_by_wallet(wallet_address: str) -> UserKYCOut | None:
    with get_session() as session: 
        entity = (
            session.query(UserKYC)
            .filter(UserKYC.wallet_address == wallet_address)
            .one_or_none()
        )
        if not entity:
            return None
        return UserKYCOut.model_validate(entity)
