// src/components/WebcamScanner.tsx

import React, { useRef, useCallback, useEffect } from 'react';
import Webcam from 'react-webcam';
import jsQR from 'jsqr';

// Definimos as propriedades que o componente receberá
interface WebcamScannerProps {
  onScanSuccess: (data: { patientName: string; date: Date }) => void;
  onScanFailure?: (error: string) => void;
}

export const WebcamScanner: React.FC<WebcamScannerProps> = ({ onScanSuccess, onScanFailure }) => {
  const webcamRef = useRef<Webcam>(null);
  const animationFrameId = useRef<number>();

  // Função para capturar e processar o frame da webcam
  const capture = useCallback(() => {
    if (webcamRef.current) {
      const imageSrc = webcamRef.current.getScreenshot();
      if (!imageSrc) {
        // Tenta novamente no próximo frame
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
        
        // Tenta decodificar o QR code da imagem
        const code = jsQR(imageData.data, imageData.width, imageData.height);

        if (code) {
          try {
            // Assumimos que o QR code contém um JSON com os dados esperados
            const parsedData = JSON.parse(code.data);
            
            // Verificamos se os dados têm o formato esperado
            if (parsedData.patientName && parsedData.date) {
               onScanSuccess({
                 ...parsedData,
                 date: new Date(parsedData.date) // Converte a string de data para um objeto Date
               });
            } else {
              throw new Error("Formato de dados do QR Code inválido.");
            }
          } catch (error) {
            console.error("Erro ao processar QR Code:", error);
            if (onScanFailure) onScanFailure("QR Code com formato inválido.");
            // Continua escaneando se o formato for inválido
            animationFrameId.current = requestAnimationFrame(capture);
          }
        } else {
          // Se nenhum QR code for encontrado, continua o loop
          animationFrameId.current = requestAnimationFrame(capture);
        }
      };
    }
  }, [onScanSuccess, onScanFailure]);

  // Inicia e para o loop de captura quando o componente é montado/desmontado
  useEffect(() => {
    animationFrameId.current = requestAnimationFrame(capture);
    return () => {
      if (animationFrameId.current) {
        cancelAnimationFrame(animationFrameId.current);
      }
    };
  }, [capture]);

  return (
    <div className="relative w-full max-w-md mx-auto border-4 border-gray-300 rounded-lg overflow-hidden">
      <Webcam
        audio={false}
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        width="100%"
        videoConstraints={{ facingMode: 'environment' }}
      />
      <div className="absolute inset-0 flex items-center justify-center p-8">
        <div className="w-full h-full border-4 border-dashed border-white opacity-75 rounded-lg" />
      </div>
       <p className="text-center mt-2 text-sm text-muted-foreground">
        Aponte a câmera para o QR Code do paciente.
      </p>
    </div>
  );
};