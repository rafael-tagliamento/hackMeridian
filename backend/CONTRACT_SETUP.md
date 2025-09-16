# ===========================================
# Configuração do Smart Contract
# ===========================================

## 1. Inicializar o Contrato

Antes de usar a API, você precisa inicializar o smart contract:

```bash
# Exemplo de comando para inicializar (ajuste conforme seu setup)
soroban contract invoke \
  --id $CONTRACT_ID \
  --source $ADMIN_SECRET_KEY \
  --network testnet \
  -- \
  initialize \
  --admin $ADMIN_PUBLIC_KEY \
  --name "VaccineNFT" \
  --symbol "VNFT"
```

## 2. Verificar se o Contrato Está Inicializado

```bash
# Verificar admin do contrato
soroban contract invoke \
  --id $CONTRACT_ID \
  --source $ADMIN_SECRET_KEY \
  --network testnet \
  -- \
  admin
```

## 3. Configurar as Variáveis de Ambiente

No arquivo `.env`:

```env
# ID do contrato implantado
VACCINE_CONTRACT_ID=CA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ

# Chave secreta da conta admin (mesma usada na inicialização)
CONTRACT_ADMIN_SECRET_KEY=SXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Chave pública da conta admin
STELLAR_PUBLIC_KEY=GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## 4. Testar a API

Após configurar corretamente:

```bash
# Iniciar a API
npm run dev

# Testar criação de token
curl -X POST http://localhost:3000/api/v1/create_vaccine \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vacina COVID-19",
    "description": "Primeira dose",
    "destination_public_key": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }'
```

## Troubleshooting

### Erro: "failed account authentication"
- Verifique se `CONTRACT_ADMIN_SECRET_KEY` é a mesma conta que inicializou o contrato
- Confirme se a conta tem saldo suficiente para fees

### Erro: "Contract not found"
- Verifique se `VACCINE_CONTRACT_ID` está correto
- Confirme se o contrato foi implantado na testnet

### Erro: "Invalid Stellar destination public key format"
- As chaves públicas devem começar com "G" e ter 56 caracteres
- Exemplo: GCF7TBDW3VZQBZ2YJRZ7W6LXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
