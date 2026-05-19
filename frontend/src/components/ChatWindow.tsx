import React from 'react';
import { MessageList } from './MessageList';
import { MessageInput } from './MessageInput';
import { LoadingIndicator } from './LoadingIndicator';
import { useChat } from '../hooks/useChat';
import '../styles/global.css';

export const ChatWindow: React.FC = () => {
  const { messages, sendMessage, clearChat, isLoading, error } = useChat();

  return (
    <div className="chat-window">
      <div className="chat-header">
        <div className="header-content">
          <h1>🛍️ Customer Support</h1>
          <p>How can we help you today?</p>
        </div>
        <button
          className="clear-button"
          onClick={clearChat}
          title="Start new conversation"
        >
          🔄 New Chat
        </button>
      </div>

      {error && <div className="error-banner">⚠️ {error}</div>}

      <MessageList messages={messages} />

      {isLoading && <LoadingIndicator />}

      <MessageInput onSendMessage={sendMessage} disabled={isLoading} />
    </div>
  );
};