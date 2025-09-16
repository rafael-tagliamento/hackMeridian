# Sistema de Validação de QR Code com Stellar

## Resumo das Alterações

Foi implementado um sistema de validação de QR Code usando a rede Stellar para autenticação de pacientes. O sistema agora:

1. **Valida a estrutura do QR Code** - Deve seguir o formato: `{"data":{"name","cpf","publicKey"},"signature"}`
2. **Autentica usando Stellar SDK** - Verifica se a assinatura é válida usando a chave pública
3. **Redireciona condicionalmente** - Se válido, vai para vaccination-lists; se inválido, mostra erro

## Arquivos Modificados

### 1. `/src/utils/stellar-validation.ts` (NOVO)
- Funções `validateQRCodeSignature()` e `validateQRCodeStructure()`
- Tipos TypeScript `QRCodeData` e `QRCodePayload`
- Validação completa usando o SDK Stellar

### 2. `/src/components/qr-scanner.tsx`
- Atualizado para usar nova estrutura de dados
- Adicionado estado 'validating' para mostrar loading durante validação
- Integração com funções de validação Stellar
- Callback `onValidationError` para tratar erros

### 3. `/src/App.tsx`
- Tipos atualizados para trabalhar com `QRCodeData` (name, cpf, publicKey)
- Estado `scanError` para tratar mensagens de erro
- Interface atualizada para mostrar dados validados do paciente
- Lógica de redirecionamento para vaccination-lists após validação

### 4. `package.json`
- Adicionado `@stellar/stellar-sdk` como dependência

## Fluxo de Funcionamento

1. **Usuário escaneia QR Code** no componente `QRScanner`
2. **Validação da estrutura** - Verifica se contém data{name,cpf,publicKey} e signature
3. **Validação da assinatura** - Usa Stellar SDK para verificar se signature é válida
4. **Se válido**: 
   - Salva dados em `scannedData`
   - Redireciona para tela de vacinação com histórico (VaccinationLists)
   - Preenche formulário com nome do paciente
5. **Se inválido**:
   - Mostra mensagem de erro específica
   - Permite tentar novamente

## Estrutura Esperada do QR Code

```json
{
  "data": {
    "name": "João Silva",
    "cpf": "12345678901", 
    "publicKey": "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ"
  },
  "signature": "base64encodedSignature"
}
```

## Estados do Scanner

- **idle**: Aguardando início do scan
- **scanning**: Escaneando QR Code
- **validating**: Validando assinatura (mostra loading)
- **error**: Erro de validação (mostra mensagem específica)

## Como a Validação Funciona

1. Parse do JSON do QR Code
2. Validação da estrutura (campos obrigatórios)
3. Verificação se publicKey é válida no formato Stellar
4. Criação do keypair a partir da publicKey
5. Verificação da assinatura dos dados usando Stellar SDK
6. Retorno true/false + mensagem de erro se aplicável

## Testes

Para testar o sistema:
1. Compile a aplicação: `npm run build`
2. Execute em desenvolvimento: `npm run dev`
3. Use um QR Code com a estrutura correta
4. A validação será executada automaticamente

O sistema está pronto para uso e totalmente integrado com a interface existente!