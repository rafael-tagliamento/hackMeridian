from pydantic import BaseModel


class VaccinationToken(BaseModel):
    """
    Data model for creating a vaccination token.
    Ensures that the data received by the API is in the correct format.
    """

    patient_id: str
    vaccine_name: str
    dose_number: int
    issuer_account: str  # Public key of the issuing account
