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
 * Validates if the QR Code signature is valid using the Stellar network
 * @param payload - The QR Code data containing data and signature
 * @returns Promise<boolean> - true if signature is valid, false otherwise
 */
export async function validateQRCodeSignature(payload: QRCodePayload): Promise<boolean> {
  try {
    const { data, signature } = payload;
    
    console.log('Validating QR Code:', { data, signature });
    
    // Validate if the publicKey is valid in Stellar format
    if (!StrKey.isValidEd25519PublicKey(data.publicKey)) {
      console.error('Invalid public key in Stellar format:', data.publicKey);
      throw new Error('Invalid public key in Stellar format');
    }

    // Create keypair from public key
    const keypair = Keypair.fromPublicKey(data.publicKey);
    console.log('Keypair created successfully');
    
    // Try different data serialization formats
    const possibleFormats = [
      // Format 1: Simple JSON stringify
      JSON.stringify(data),
      // Format 2: JSON stringify with ordered fields
      JSON.stringify({
        name: data.name,
        cpf: data.cpf,
        publicKey: data.publicKey
      }),
      // Format 3: JSON stringify without spaces
      JSON.stringify(data, null, 0),
      // Format 4: Concatenated string
      `${data.name}${data.cpf}${data.publicKey}`,
      // Format 5: With separators
      `${data.name}|${data.cpf}|${data.publicKey}`,
      // Format 6: Just the data object as string
      JSON.stringify(data, Object.keys(data).sort())
    ];
    
    console.log('Testing data formats...');
    
    for (let i = 0; i < possibleFormats.length; i++) {
      const dataToVerify = possibleFormats[i];
      console.log(`Testing format ${i + 1}:`, dataToVerify);
      
      try {
        // Convert signature from base64 to Buffer
        const signatureBuffer = Buffer.from(signature, 'base64');
        console.log('Signature buffer length:', signatureBuffer.length);
        
        // Convert data to Buffer
        const dataBuffer = Buffer.from(dataToVerify, 'utf8');
        
        // Verify signature
        const isValid = keypair.verify(dataBuffer, signatureBuffer);
        console.log(`Format ${i + 1} valid:`, isValid);
        
        if (isValid) {
          console.log('✅ Valid signature found with format:', i + 1);
          console.log('Data used:', dataToVerify);
          return true;
        }
      } catch (error) {
        console.log(`Error in format ${i + 1}:`, error);
      }
    }
    
    console.log('❌ No signature format was valid');
    throw new Error('QR Code altered or incompatible key');
    
  } catch (error) {
    console.error('Error validating QR Code signature:', error);
    if (error instanceof Error) {
      throw error; // Re-throw to maintain specific message
    }
    throw new Error('Error in digital signature validation');
  }
}

/**
 * Validates if the QR Code payload has the correct structure
 * @param parsedData - Parsed QR Code data
 * @returns boolean - true if structure is valid
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