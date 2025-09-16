from datetime import datetime, timezone
from sqlalchemy import String, DateTime, Integer, UniqueConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column, DeclarativeBase


# SQLAlchemy base class
class Base(DeclarativeBase):
    pass


class UserKYC(Base):
    __tablename__ = "user_kyc"
    __table_args__ = (
        UniqueConstraint("wallet_address", name="uq_user_wallet"),
        # Evita duplicidade do mesmo documento
        UniqueConstraint("document_id", name="uq_doc"),
        Index("ix_user_kyc_created_at", "created_at"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    wallet_address: Mapped[str] = mapped_column(String(120), index=True)
    full_name: Mapped[str] = mapped_column(String(150))
    document_id: Mapped[str] = mapped_column(String(80), index=True)
    id_photo_ref: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
