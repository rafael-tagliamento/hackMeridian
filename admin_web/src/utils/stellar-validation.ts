import { Keypair, StrKey } from '@stellar/stellar-sdk';
import { Buffer } from 'buffer';

export interface QRCodeData {
  name: string;
  cpf: string;
  publicKey: string;
}

export interface QRCodePayload {
  data: QRCodeData;
  signature: string;
}

/**
 * Valida se a assinatura do QR Code é válida usando a rede Stellar
 * @param payload - Os dados do QR Code contendo data e signature
 * @returns Promise<boolean> - true se a assinatura for válida, false caso contrário
 */
export async function validateQRCodeSignature(payload: QRCodePayload): Promise<boolean> {
  try {
    const { data, signature } = payload;
    
    console.log('Validando QR Code:', { data, signature });
    
    // Validar se a publicKey é válida no formato Stellar
    if (!StrKey.isValidEd25519PublicKey(data.publicKey)) {
      console.error('Chave pública inválida no formato Stellar:', data.publicKey);
      throw new Error('Chave pública inválida no formato Stellar');
    }

    // Criar keypair a partir da chave pública
    const keypair = Keypair.fromPublicKey(data.publicKey);
    console.log('Keypair criado com sucesso');
    
    // Tentar diferentes formatos de serialização dos dados
    const possibleFormats = [
      // Formato 1: JSON stringify simples
      JSON.stringify(data),
      // Formato 2: JSON stringify com campos ordenados
      JSON.stringify({
        name: data.name,
        cpf: data.cpf,
        publicKey: data.publicKey
      }),
      // Formato 3: JSON stringify sem espaços
      JSON.stringify(data, null, 0),
      // Formato 4: String concatenada
      `${data.name}${data.cpf}${data.publicKey}`,
      // Formato 5: Com separadores
      `${data.name}|${data.cpf}|${data.publicKey}`,
      // Formato 6: Só o objeto data como string
      JSON.stringify(data, Object.keys(data).sort())
    ];
    
    console.log('Testando formatos de dados...');
    
    for (let i = 0; i < possibleFormats.length; i++) {
      const dataToVerify = possibleFormats[i];
      console.log(`Testando formato ${i + 1}:`, dataToVerify);
      
      try {
        // Converter a assinatura de base64 para Buffer
        const signatureBuffer = Buffer.from(signature, 'base64');
        console.log('Signature buffer length:', signatureBuffer.length);
        
        // Converter dados para Buffer
        const dataBuffer = Buffer.from(dataToVerify, 'utf8');
        
        // Verificar a assinatura
        const isValid = keypair.verify(dataBuffer, signatureBuffer);
        console.log(`Formato ${i + 1} válido:`, isValid);
        
        if (isValid) {
          console.log('✅ Assinatura válida encontrada com formato:', i + 1);
          console.log('Dados usados:', dataToVerify);
          return true;
        }
      } catch (error) {
        console.log(`Erro no formato ${i + 1}:`, error);
      }
    }
    
    console.log('❌ Nenhum formato de assinatura foi válido');
    throw new Error('QR Code alterado ou com chave incompatível');
    
  } catch (error) {
    console.error('Erro ao validar assinatura do QR Code:', error);
    if (error instanceof Error) {
      throw error; // Re-throw para manter a mensagem específica
    }
    throw new Error('Erro na validação da assinatura digital');
  }
}

/**
 * Valida se o payload do QR Code tem a estrutura correta
 * @param parsedData - Dados parseados do QR Code
 * @returns boolean - true se a estrutura for válida
 */
export function validateQRCodeStructure(parsedData: any): parsedData is QRCodePayload {
  const isValid = (
    parsedData &&
    typeof parsedData === 'object' &&
    parsedData.data &&
    typeof parsedData.data === 'object' &&
    typeof parsedData.data.name === 'string' &&
    typeof parsedData.data.cpf === 'string' &&
    typeof parsedData.data.publicKey === 'string' &&
    typeof parsedData.signature === 'string'
  );
  
  console.log('Validação de estrutura:', {
    hasData: !!parsedData?.data,
    hasName: typeof parsedData?.data?.name === 'string',
    hasCpf: typeof parsedData?.data?.cpf === 'string',
    hasPublicKey: typeof parsedData?.data?.publicKey === 'string',
    hasSignature: typeof parsedData?.signature === 'string',
    isValid
  });
  
  return isValid;
}

/**
 * Função para debug - mostra detalhes do QR Code
 * @param qrCodeText - Texto do QR Code
 */
export function debugQRCode(qrCodeText: string) {
  try {
    console.log('=== DEBUG QR CODE ===');
    console.log('Texto do QR Code:', qrCodeText);
    
    const parsed = JSON.parse(qrCodeText);
    console.log('Dados parseados:', parsed);
    
    const isValidStructure = validateQRCodeStructure(parsed);
    console.log('Estrutura válida:', isValidStructure);
    
    if (isValidStructure) {
      console.log('Dados extraídos:', {
        name: parsed.data.name,
        cpf: parsed.data.cpf,
        publicKey: parsed.data.publicKey,
        signature: parsed.signature,
        signatureLength: parsed.signature.length
      });
      
      // Tentar decodificar a assinatura
      try {
        const sigBuffer = Buffer.from(parsed.signature, 'base64');
        console.log('Signature buffer length:', sigBuffer.length);
        console.log('Signature buffer (hex):', sigBuffer.toString('hex'));
      } catch (e) {
        console.log('Erro ao decodificar signature:', e);
      }
    }
    
    console.log('=== FIM DEBUG ===');
    return parsed;
    
  } catch (error) {
    console.error('Erro no debug do QR Code:', error);
    return null;
  }
}