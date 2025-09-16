import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { ScanLine, QrCode } from 'lucide-react';

interface QRScannerProps {
  onScanSuccess: (data: { patientName: string; date: Date }) => void;
}

export const QRScanner: React.FC<QRScannerProps> = ({ onScanSuccess }) => {
  const [isScanning, setIsScanning] = useState(false);
  const [scanningProgress, setScanningProgress] = useState(0);

  const handleStartScan = () => {
    setIsScanning(true);
    setScanningProgress(0);
    
    // Simular progresso do scan
    const interval = setInterval(() => {
      setScanningProgress(prev => {
        if (prev >= 100) {
          clearInterval(interval);
          setIsScanning(false);
          // Simular dados do QR code escaneado
          onScanSuccess({
            patientName: 'João Silva Santos',
            date: new Date()
          });
          return 0;
        }
        return prev + 10;
      });
    }, 200);
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
            {/* Área do scanner */}
            <div 
              className="relative border-2 border-dashed rounded-lg p-8 text-center"
              style={{ 
                borderColor: isScanning ? '#B589FF' : '#C89DFF',
                backgroundColor: isScanning ? '#FEF2FA' : 'transparent'
              }}
            >
              {!isScanning ? (
                <div className="space-y-4">
                  <QrCode className="h-16 w-16 mx-auto" style={{ color: '#C89DFF' }} />
                  <p className="text-sm text-muted-foreground">
                    Clique no botão abaixo para escanear o QR Code do paciente
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="relative">
                    <QrCode className="h-16 w-16 mx-auto" style={{ color: '#B589FF' }} />
                    <div 
                      className="absolute inset-0 flex items-center justify-center"
                      style={{
                        background: `linear-gradient(to bottom, transparent ${scanningProgress}%, rgba(181, 137, 255, 0.3) ${scanningProgress}%, rgba(181, 137, 255, 0.3) ${scanningProgress + 10}%, transparent ${scanningProgress + 10}%)`
                      }}
                    >
                      <ScanLine className="h-12 w-12 animate-pulse" style={{ color: '#B589FF' }} />
                    </div>
                  </div>
                  <p className="text-sm" style={{ color: '#B589FF' }}>
                    Escaneando... {scanningProgress}%
                  </p>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="h-2 rounded-full transition-all duration-200"
                      style={{ 
                        backgroundColor: '#B589FF',
                        width: `${scanningProgress}%`
                      }}
                    />
                  </div>
                </div>
              )}
            </div>

            {/* Botão de scan */}
            <Button
              onClick={handleStartScan}
              disabled={isScanning}
              className="w-full"
              style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}
            >
              {isScanning ? 'Escaneando...' : 'Iniciar Escaneamento'}
            </Button>

            <div className="text-xs text-muted-foreground text-center">
              O QR Code deve conter as informações do paciente para registro da vacinação
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};