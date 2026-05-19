import React, { useState } from 'react';
import { SourceCitation as SourceType } from '../types/chat.types';

interface SourceCitationProps {
  sources: SourceType[];
}

export const SourceCitation: React.FC<SourceCitationProps> = ({ sources }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="source-citation">
      <button className="source-toggle" onClick={() => setExpanded(!expanded)}>
        📚 Sources ({sources.length}) {expanded ? '▼' : '▶'}
      </button>

      {expanded && (
        <div className="source-list">
          {sources.map((source, index) => (
            <div key={index} className="source-item">
              <div className="source-header">
                <span className="source-title">{source.source}</span>
                <span className="source-score">
                  Relevance: {(source.score * 100).toFixed(0)}%
                </span>
              </div>
              <div className="source-content">{source.content}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};