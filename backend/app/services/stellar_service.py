import soroban
from soroban import Parameters, Parameter  # (mantidos se futuro for corrigir lib)
from stellar_sdk import Keypair, scval
from stellar_sdk.xdr import TransactionResult
from ..core.config import settings
from ..models.vaccination_token import VaccinationTokenBase
import logging
import base64
from typing import Any, Dict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def _decode_result_xdr(result_xdr: str) -> Dict[str, Any]:
    """Best-effort decode of a Soroban transaction result XDR for diagnostics."""
    try:
        tr = TransactionResult.from_xdr(result_xdr)
        op_results = []
        if tr.result.results:
            for r in tr.result.results:
                invoke_code = None
                if r.tr and r.tr.invoke_host_function_result:
                    invoke_code = r.tr.invoke_host_function_result.code
                op_results.append(
                    {
                        "operation_code": r.code,
                        "invoke_host_function_code": invoke_code,
                    }
                )
        return {
            "fee_charged": tr.fee_charged.int64,
            "tx_code": tr.result.code,  # -1 = txFAILED
            "operations": op_results,
        }
    except Exception as e:  # pragma: no cover - defensive
        return {"decode_error": str(e)}


def create_vac_token(token_data: VaccinationTokenBase, destination_key: str):
    """Cria e emite um novo token de vacinação em Soroban."""
    logger.info("Iniciando criação de token de vacinação")
    logger.debug("Payload recebido: %s", token_data.model_dump())

    # Validar campos básicos (ex: datas lógicas)
    if token_data.expiration_date <= token_data.taken_date:
        return {
            "status": "error",
            "message": "expiration_date deve ser maior que taken_date",
        }

    # Unix timestamps
    exp_date_timestamp = int(token_data.expiration_date.timestamp())
    taken_date_timestamp = int(token_data.taken_date.timestamp())

    identity = soroban.Identity(
        secret_key=settings.STELLAR_SECRET_KEY,
        public_key=settings.STELLAR_PUBLIC_KEY,
    )
    network = soroban.NetworkConfig(  # type: ignore[arg-type]
        rpc_url="https://soroban-testnet.stellar.org",  # type: ignore[arg-type]
        horizon_url="https://horizon-testnet.stellar.org",  # type: ignore[arg-type]
    )

    # Contorno: gerar SCVals manualmente devido a possível bug em Parameter.value_to_scval
    try:
        sc_args = [
            scval.to_address(destination_key),
            scval.to_string(token_data.name),
            scval.to_string(token_data.batch),
            scval.to_uint64(exp_date_timestamp),
            scval.to_uint64(taken_date_timestamp),
        ]
    except Exception as conv_err:
        logger.error("Erro convertendo argumentos para SCVal: %s", conv_err)
        return {
            "status": "error",
            "message": f"Falha na conversão de argumentos: {conv_err}",
        }

    logger.debug(
        "Invocando contrato %s função %s args=%s destino=%s",
        settings.VACCINE_CONTRACT_ID,
        "mint_with_attrs",
        sc_args,
        destination_key,
    )

    try:
        response = soroban.invoke(
            settings.VACCINE_CONTRACT_ID,
            "mint_with_attrs",
            args=sc_args,
            source_account=identity,
            network=network,
        )
        # A lib retorna estrutura com sucesso? Podemos logar para depurar.
        logger.info("Transação submetida com sucesso: %s", response)
        return {"status": "success", "response": response}
    except Exception as e:
        # Tentar extrair XDR se disponível na exception string
        msg = str(e)
        decoded = None
        if "'" in msg:
            # heuristic: último token base64 entre aspas simples
            parts = [
                p
                for p in msg.split("'")
                if len(p) >= 16
                and set(p)
                <= set(
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
                )
            ]
            if parts:
                decoded = _decode_result_xdr(parts[-1])
        logger.error("Falha ao invocar contrato: %s decoded=%s", msg, decoded)
        return {
            "status": "error",
            "message": msg,
            "decoded_result": decoded,
        }
