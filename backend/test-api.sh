# ===========================================
# Exemplos de Requisições - Vaccine API
# ===========================================

# ⚠️ IMPORTANTE: Antes de executar, configure corretamente:
# 1. VACCINE_CONTRACT_ID no .env
# 2. CONTRACT_ADMIN_SECRET_KEY no .env (mesma conta que inicializou o contrato)
# 3. Leia CONTRACT_SETUP.md para instruções completas

echo "=== Testando API de Vacinação ==="
echo ""

# 1. CRIAR TOKEN NFT DE VACINA
echo "1. Criando token NFT de vacina..."
curl -X POST http://localhost:3000/api/v1/create_vaccine \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vacina COVID-19",
    "description": "Primeira dose da vacina COVID-19",
    "destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "batch": "LOTE-2024-001",
    "exp_date": 1704067200000,
    "taken_date": 1701388800000
  }'

echo -e "\n\n"

# 2. VERIFICAR TOKEN NFT
echo "2. Verificando token NFT..."
curl http://localhost:3000/api/v1/verify_vaccine/1

echo -e "\n\n"

# 3. REGISTRAR USUÁRIO KYC
echo "3. Registrando usuário KYC..."
curl -X POST http://localhost:3000/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "wallet_address": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "full_name": "João Silva",
    "document_id": "123456789",
    "id_photo_ref": "ipfs://QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }'

echo -e "\n\n"

# 4. CONSULTAR USUÁRIO POR WALLET
echo "4. Consultando usuário por wallet..."
curl http://localhost:3000/api/v1/users/GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

echo -e "\n\n"

# 5. ENDPOINT RAIZ
echo "5. Testando endpoint raiz..."
curl http://localhost:3000/

echo -e "\n\n=== FIM DOS EXEMPLOS ==="
echo "📝 Lembre-se de configurar CONTRACT_ADMIN_SECRET_KEY corretamente!"
