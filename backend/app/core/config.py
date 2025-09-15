from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Manages all environment variables and application secrets.
    """

    STELLAR_SECRET_KEY: str
    STELLAR_PUBLIC_KEY: str
    STELLAR_NETWORK_URL: str = "https://horizon-testnet.stellar.org"  # Testnet URL
    # Database URL (SQLite local por padrão)
    DB_URL: str = "sqlite:///./vaccine.db"

    class Config:
        env_file = ".env"


settings = Settings()
