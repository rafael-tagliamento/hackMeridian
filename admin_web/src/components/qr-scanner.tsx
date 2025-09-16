import React, { useState, useRef, useCallback, useEffect } from 'react';
import Webcam from 'react-webcam';
import jsQR from 'jsqr';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { ScanLine, QrCode } from 'lucide-react';

interface QRScannerProps {
  onScanSuccess: (data: { patientName: string; date: Date }) => void;
}

// Um tipo para controlar os diferentes estados do nosso componente
type ScanState = 'idle' | 'scanning' | 'error';

export const QRScanner: React.FC<QRScannerProps> = ({ onScanSuccess }) => {
  const [scanState, setScanState] = useState<ScanState>('idle');
  const webcamRef = useRef<Webcam>(null);
  const animationFrameId = useRef<number>();

  // Lógica de captura e decodificação do QR Code (a mesma que fizemos antes)
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
      image.onload = () => {
        canvas.width = image.width;
        canvas.height = image.height;
        ctx.drawImage(image, 0, 0, image.width, image.height);
        const imageData = ctx.getImageData(0, 0, image.width, image.height);
        const code = jsQR(imageData.data, imageData.width, imageData.height);

        if (code) {
          try {
            // Assumimos que o QR code contém um JSON
            const parsedData = JSON.parse(code.data);
            if (parsedData.patientName && parsedData.date) {
               // Sucesso! Chamamos a função e paramos o scan.
               onScanSuccess({
                 ...parsedData,
                 date: new Date(parsedData.date)
               });
               setScanState('idle'); // Retorna ao estado inicial
            } else {
              throw new Error("Formato de dados do QR Code inválido.");
            }
          } catch (error) {
            console.error("Erro ao processar QR Code:", error);
            setScanState('error');
          }
        } else {
          // Nenhum QR code encontrado, continua o loop
          animationFrameId.current = requestAnimationFrame(capture);
        }
      };
    }
  }, [onScanSuccess]);

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
                    Clique no botão para ativar a câmera e escanear
                  </p>
                </div>
              )}
              {scanState === 'error' && (
                <div className="space-y-4 p-6">
                   <p className="text-sm text-red-500">
                    Não foi possível ler o QR Code. Tente novamente.
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
              disabled={scanState === 'scanning'}
              className="w-full"
              style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}
            >
              {scanState === 'scanning' ? 'Escaneando...' : 'Iniciar Escaneamento'}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};