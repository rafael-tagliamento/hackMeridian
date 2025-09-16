// Teste básico da validação de QR Code
import { validateQRCodeSignature, validateQRCodeStructure } from '../src/utils/stellar-validation';

// Exemplo de uso para teste (apenas para demonstração)
const exemploQRCode = {
  data: {
    name: "João Silva", 
    cpf: "12345678901",
    publicKey: "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ"
  },
  signature: "base64signature..."
};

console.log('Estrutura válida:', validateQRCodeStructure(exemploQRCode));
console.log('QR Code de teste:', JSON.stringify(exemploQRCode, null, 2));