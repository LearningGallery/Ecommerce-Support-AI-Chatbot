import React from 'react';

export const LoadingIndicator: React.FC = () => {
  return (
    <div className="loading-indicator">
      <div className="loading-dots">
        <span className="dot"></span>
        <span className="dot"></span>
        <span className="dot"></span>
      </div>
      <span className="loading-text">Thinking...</span>
    </div>
  );
};