import React from 'react';

interface SyringeIconProps {
  className?: string;
  size?: number;
}

export const SyringeIcon: React.FC<SyringeIconProps> = ({ 
  className = "", 
  size = 24 
}) => {
  return (
    <svg 
      width={size} 
      height={size} 
      viewBox="0 0 24 24" 
      fill="none" 
      className={className}
    >
      {/* Seringa com gradiente azul e roxo */}
      <defs>
        <linearGradient id="syringeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#92B8FE" />
          <stop offset="100%" stopColor="#B589FF" />
        </linearGradient>
      </defs>
      
      {/* Corpo da seringa */}
      <rect 
        x="3" 
        y="8" 
        width="14" 
        height="4" 
        rx="2" 
        fill="url(#syringeGradient)" 
      />
      
      {/* Êmbolo */}
      <rect 
        x="1" 
        y="9" 
        width="3" 
        height="2" 
        rx="1" 
        fill="#B589FF" 
      />
      
      {/* Agulha */}
      <rect 
        x="17" 
        y="9.5" 
        width="5" 
        height="1" 
        fill="#92B8FE" 
      />
      
      {/* Ponta da agulha */}
      <polygon 
        points="22,10 23,9.5 23,10.5" 
        fill="#92B8FE" 
      />
      
      {/* Marcações na seringa */}
      <line x1="6" y1="8.5" x2="6" y2="11.5" stroke="#FEF2FA" strokeWidth="0.5" />
      <line x1="9" y1="8.5" x2="9" y2="11.5" stroke="#FEF2FA" strokeWidth="0.5" />
      <line x1="12" y1="8.5" x2="12" y2="11.5" stroke="#FEF2FA" strokeWidth="0.5" />
      <line x1="15" y1="8.5" x2="15" y2="11.5" stroke="#FEF2FA" strokeWidth="0.5" />
    </svg>
  );
};