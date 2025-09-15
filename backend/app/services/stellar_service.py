from stellar_sdk import Server, Keypair, TransactionBuilder, Network, Asset
from ..core.config import settings
from ..models.vacination_token import VaccinationToken

def create_vac_token(token_data: VaccinationToken):
    """
    Creates and issues a new vaccination token on the Stellar network.
    """
    server = Server(horizon_url=settings.STELLAR_NETWORK_URL)
    source_keypair = Keypair.from_secret(settings.STELLAR_SECRET_KEY)

    # In a real application, the destination would be the patient's public key
    # For this example, we'll use a newly generated keypair
    destination_keypair = Keypair.random()

    # Create a custom asset representing the vaccine
    vaccine_asset = Asset(token_data.vaccine_name, source_keypair.public_key)

    # Build the transaction
    transaction = (
        TransactionBuilder(
            source_account=server.load_account(source_keypair.public_key),
            network_passphrase=Network.TESTNET_NETWORK_PASSPHRASE,
            base_fee=100,
        )
        # First, the destination account must trust the asset
        .append_change_trust_op(
            asset=vaccine_asset,
            source=destination_keypair.public_key # The patient's account trusts the asset
        )
        # Then, the issuer sends the token
        .append_payment_op(
            destination=destination_keypair.public_key,
            asset=vaccine_asset,
            amount="1", # Issue one token representing one dose
        )
        .build()
    )

    # The issuer and the patient must sign the transaction
    transaction.sign(source_keypair)
    transaction.sign(destination_keypair)

    # Submit to the network
    try:
        response = server.submit_transaction(transaction)
        return {"status": "success", "tx_hash": response["hash"]}
    except Exception as e:
        return {"status": "error", "message": str(e)}


def verify_token_on_chain(asset_code: str, issuer_account: str):
    """
    Verifies if a specific token exists on the Stellar network.
    """
    server = Server(horizon_url=settings.STELLAR_NETWORK_URL)
    try:
        # Check if the asset exists
        assets = server.assets().for_code(asset_code).for_issuer(issuer_account).call()
        if assets["_embedded"]["records"]:
            return True
        return False
    except Exception:
        return False
