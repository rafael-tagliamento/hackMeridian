import React, { useState, useRef, useCallback, useEffect } from 'react';
import Webcam from 'react-webcam';
import jsQR from 'jsqr';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { ScanLine, QrCode } from 'lucide-react';
import { validateQRCodeSignature, validateQRCodeStructure, QRCodeData, debugQRCode } from '../utils/stellar-validation';

interface QRScannerProps {
  onScanSuccess: (data: QRCodeData) => void;
  onValidationError: (message: string) => void;
}

// Um tipo para controlar os diferentes estados do nosso componente
type ScanState = 'idle' | 'scanning' | 'validating' | 'error';

export const QRScanner: React.FC<QRScannerProps> = ({ onScanSuccess, onValidationError }) => {
  const [scanState, setScanState] = useState<ScanState>('idle');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const webcamRef = useRef<Webcam>(null);
  const animationFrameId = useRef<number | undefined>(undefined);

  // Lógica de captura e decodificação do QR Code com validação Stellar
  const capture = useCallback(() => {
    if (webcamRef.current) {
      const imageSrc = webcamRef.current.getScreenshot();
      if (!imageSrc) {
        animationFrameId.current = requestAnimationFrame(capture);
        return;
      }
      
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) return;

      const image = new Image();
      image.src = imageSrc;
      image.onload = async () => {
        canvas.width = image.width;
        canvas.height = image.height;
        ctx.drawImage(image, 0, 0, image.width, image.height);
        const imageData = ctx.getImageData(0, 0, image.width, image.height);
        const code = jsQR(imageData.data, imageData.width, imageData.height);

        if (code) {
          try {
            console.log('QR Code detectado!');
            
            // Debug completo do QR Code
            const debugResult = debugQRCode(code.data);
            
            // Parse do JSON do QR code
            const parsedData = JSON.parse(code.data);
            
            // Validar estrutura do QR code
            if (!validateQRCodeStructure(parsedData)) {
              throw new Error("Formato de QR Code inválido. Esperado: {\"data\":{\"name\",\"cpf\",\"publicKey\"},\"signature\"}");
            }

            // Alterar estado para validando
            setScanState('validating');
            setErrorMessage('');

            // Validar assinatura usando Stellar SDK
            const isSignatureValid = await validateQRCodeSignature(parsedData);
            
            if (isSignatureValid) {
              // Assinatura válida - sucesso!
              console.log('✅ QR Code válido! Redirecionando...');
              onScanSuccess(parsedData.data);
              setScanState('idle');
            } else {
              // Assinatura inválida
              const errorMsg = "QR Code inválido: assinatura não confere com a chave pública";
              setErrorMessage(errorMsg);
              onValidationError(errorMsg);
              setScanState('error');
            }
          } catch (error) {
            console.error("Erro ao processar QR Code:", error);
            const errorMsg = error instanceof Error ? error.message : "Erro ao processar QR Code";
            setErrorMessage(errorMsg);
            onValidationError(errorMsg);
            setScanState('error');
          }
        } else {
          // Nenhum QR code encontrado, continua o loop
          animationFrameId.current = requestAnimationFrame(capture);
        }
      };
    }
  }, [onScanSuccess, onValidationError]);

  // useEffect para controlar o início e o fim do loop de escaneamento
  useEffect(() => {
    if (scanState === 'scanning') {
      // Inicia o escaneamento
      animationFrameId.current = requestAnimationFrame(capture);
    } else {
      // Para o escaneamento se o estado não for 'scanning'
      if (animationFrameId.current) {
        cancelAnimationFrame(animationFrameId.current);
      }
    }

    // Função de limpeza para parar o loop quando o componente for desmontado
    return () => {
      if (animationFrameId.current) {
        cancelAnimationFrame(animationFrameId.current);
      }
    };
  }, [scanState, capture]);
  
  const handleStartScan = () => {
    setErrorMessage(''); // Limpa mensagem de erro anterior
    setScanState('scanning');
  };

  return (
    <div className="max-w-md mx-auto">
      <Card>
        <CardHeader className="text-center">
          <CardTitle className="flex items-center justify-center gap-2">
            <QrCode className="h-6 w-6" style={{ color: '#B589FF' }} />
            Scanner de QR Code
          </CardTitle>
        </CardHeader>
        <CardContent className="p-6">
          <div className="space-y-6">
            {/* Área do scanner que agora mostra a câmera real */}
            <div className="relative border-2 border-dashed rounded-lg p-2 text-center overflow-hidden">
              {scanState === 'idle' && (
                <div className="space-y-4 p-6">
                  <QrCode className="h-16 w-16 mx-auto" style={{ color: '#C89DFF' }} />
                  <p className="text-sm text-muted-foreground">
                    Clique no botão para ativar a câmera e escanear um QR Code válido
                  </p>
                </div>
              )}
              {scanState === 'error' && (
                <div className="space-y-4 p-6">
                   <p className="text-sm text-red-500">
                    {errorMessage || "Não foi possível ler o QR Code. Tente novamente."}
                  </p>
                </div>
              )}
              {scanState === 'validating' && (
                <div className="space-y-4 p-6">
                  <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-purple-600 mx-auto"></div>
                  <p className="text-sm text-muted-foreground">
                    Validando assinatura...
                  </p>
                </div>
              )}
              {scanState === 'scanning' && (
                <div className="relative">
                  <Webcam
                    audio={false}
                    ref={webcamRef}
                    screenshotFormat="image/jpeg"
                    videoConstraints={{ facingMode: 'environment' }}
                    className="w-full h-auto rounded-md"
                  />
                  {/* Animação da linha de scan sobre a imagem da câmera */}
                  <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                     <div className="w-full h-1/2 border-y-4 border-white/50 animate-pulse" />
                     <ScanLine className="h-12 w-12 text-white/80 absolute" />
                  </div>
                </div>
              )}
            </div>

            <Button
              onClick={handleStartScan}
              disabled={scanState === 'scanning' || scanState === 'validating'}
              className="w-full"
              style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}
            >
              {scanState === 'scanning' ? 'Escaneando...' : 
               scanState === 'validating' ? 'Validando...' : 
               scanState === 'error' ? 'Tentar Novamente' :
               'Iniciar Escaneamento'}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};