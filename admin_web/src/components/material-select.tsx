import React, { useState } from 'react';
import { ChevronDown, Check } from 'lucide-react';
import { Card, CardContent } from './ui/card';

interface Option {
  value: string;
  label: string;
}

interface MaterialSelectProps {
  options: Option[];
  value: string;
  onValueChange: (value: string) => void;
  placeholder: string;
  label: string;
  required?: boolean;
}

export const MaterialSelect: React.FC<MaterialSelectProps> = ({
  options,
  value,
  onValueChange,
  placeholder,
  label,
  required = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [isFocused, setIsFocused] = useState(false);

  const selectedOption = options.find(option => option.value === value);
  const hasValue = Boolean(selectedOption);

  const handleSelect = (optionValue: string) => {
    onValueChange(optionValue);
    setIsOpen(false);
  };

  return (
    <div className="relative">
      {/* Label */}
      <label 
        className={`absolute left-4 transition-all duration-200 ease-out pointer-events-none z-10 ${
          hasValue || isFocused 
            ? 'top-2 text-xs' 
            : 'top-6 text-base'
        }`}
        style={{ 
          color: hasValue || isFocused ? '#B589FF' : '#717182',
          backgroundColor: hasValue || isFocused ? '#ffffff' : 'transparent',
          padding: hasValue || isFocused ? '0 4px' : '0'
        }}
      >
        {label} {required && '*'}
      </label>

      {/* Select Trigger */}
      <div 
        className="relative cursor-pointer"
        onClick={() => {
          setIsOpen(!isOpen);
          setIsFocused(!isOpen);
        }}
        onBlur={() => setIsFocused(false)}
      >
        <div 
          className={`w-full h-14 px-4 pt-6 pb-2 rounded-lg border-2 bg-white transition-all duration-200 flex items-end justify-between ${
            isFocused || isOpen 
              ? 'border-[#B589FF] shadow-md' 
              : 'border-gray-300 hover:border-gray-400'
          }`}
        >
          <div className="flex-1">
            {selectedOption ? (
              <span className="text-base">{selectedOption.label}</span>
            ) : (
              <span className="text-gray-400 text-base">{placeholder}</span>
            )}
          </div>
          <ChevronDown 
            className={`h-5 w-5 transition-transform duration-200 ${
              isOpen ? 'rotate-180' : ''
            }`}
            style={{ color: isFocused ? '#B589FF' : '#717182' }}
          />
        </div>
      </div>

      {/* Dropdown Options */}
      {isOpen && (
        <Card className="absolute top-full left-0 right-0 mt-2 z-50 shadow-lg border-2" style={{ borderColor: '#B589FF' }}>
          <CardContent className="p-0 max-h-60 overflow-y-auto">
            {options.map((option, index) => (
              <div
                key={option.value}
                className={`px-4 py-3 cursor-pointer transition-colors duration-150 flex items-center justify-between hover:bg-gray-50 ${
                  index !== options.length - 1 ? 'border-b border-gray-100' : ''
                }`}
                onClick={() => handleSelect(option.value)}
                style={{
                  backgroundColor: option.value === value ? '#FEF2FA' : 'transparent'
                }}
              >
                <span className="text-base">{option.label}</span>
                {option.value === value && (
                  <Check className="h-4 w-4" style={{ color: '#B589FF' }} />
                )}
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Overlay to close dropdown */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-40"
          onClick={() => {
            setIsOpen(false);
            setIsFocused(false);
          }}
        />
      )}
    </div>
  );
};