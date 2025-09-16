import React from 'react';

interface BlockchainIconProps {
  className?: string;
  size?: number;
}

export const BlockchainIcon: React.FC<BlockchainIconProps> = ({ 
  className = "", 
  size = 16 
}) => {
  return (
    <svg 
      width={size} 
      height={size} 
      viewBox="0 0 24 24" 
      fill="none" 
      className={className}
    >
      {/* Blocos da blockchain */}
      <rect 
        x="2" 
        y="8" 
        width="6" 
        height="6" 
        rx="1" 
        fill="#B589FF" 
        stroke="#92B8FE" 
        strokeWidth="1" 
      />
      <rect 
        x="9" 
        y="8" 
        width="6" 
        height="6" 
        rx="1" 
        fill="#B589FF" 
        stroke="#92B8FE" 
        strokeWidth="1" 
      />
      <rect 
        x="16" 
        y="8" 
        width="6" 
        height="6" 
        rx="1" 
        fill="#B589FF" 
        stroke="#92B8FE" 
        strokeWidth="1" 
      />
      
      {/* Conexões entre blocos */}
      <line x1="8" y1="11" x2="9" y2="11" stroke="#92B8FE" strokeWidth="2" />
      <line x1="15" y1="11" x2="16" y2="11" stroke="#92B8FE" strokeWidth="2" />
      
      {/* Pequenos quadrados internos para representar dados */}
      <rect x="3.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="5.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="3.5" y="11.5" width="1" height="1" fill="#92B8FE" />
      <rect x="5.5" y="11.5" width="1" height="1" fill="#92B8FE" />
      
      <rect x="10.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="12.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="10.5" y="11.5" width="1" height="1" fill="#92B8FE" />
      <rect x="12.5" y="11.5" width="1" height="1" fill="#92B8FE" />
      
      <rect x="17.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="19.5" y="9.5" width="1" height="1" fill="#92B8FE" />
      <rect x="17.5" y="11.5" width="1" height="1" fill="#92B8FE" />
      <rect x="19.5" y="11.5" width="1" height="1" fill="#92B8FE" />
    </svg>
  );
};