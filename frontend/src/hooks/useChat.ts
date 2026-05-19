import { useCallback, useEffect, useState } from 'react';
import { ChatRequest, Message } from '../types/chat.types';
import { chatService } from '../services/chatService';

export const useChat = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const initSession = async () => {
      try {
        const session = await chatService.createSession();
        setSessionId(session.session_id);

        const welcomeMessage: Message = {
          id: 'welcome',
          role: 'assistant',
          content:
            "Hello! 👋 I'm your customer support assistant. I can help you with:\n\n• Order status and tracking\n• Shipping and delivery questions\n• Returns and refunds\n• Product information\n• Payment methods\n• Account issues\n\nWhat can I help you with today?",
          timestamp: new Date(),
        };

        setMessages([welcomeMessage]);
      } catch (err) {
        console.error('Failed to initialize session:', err);
        setError('Failed to start chat session. Please refresh the page.');
      }
    };

    initSession();
  }, []);

  const sendMessage = useCallback(
    async (content: string) => {
      if (!sessionId || !content.trim()) return;

      setError(null);
      setIsLoading(true);

      const userMessage: Message = {
        id: `user-${Date.now()}`,
        role: 'user',
        content: content.trim(),
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, userMessage]);

      try {
        const request: ChatRequest = {
          message: content.trim(),
          session_id: sessionId,
          user_id: 'anonymous',
          use_rag: true,
          include_history: true,
        };

        const response = await chatService.sendMessage(request);

        const assistantMessage: Message = {
          id: `assistant-${Date.now()}`,
          role: 'assistant',
          content: response.message,
          timestamp: new Date(response.timestamp),
          sources: response.sources,
        };

        setMessages((prev) => [...prev, assistantMessage]);
      } catch (err) {
        console.error('Failed to send message:', err);
        setError('Failed to send message. Please try again.');

        const errorMessage: Message = {
          id: `error-${Date.now()}`,
          role: 'assistant',
          content:
            'I apologize, but I encountered an error processing your request. Please try again.',
          timestamp: new Date(),
        };

        setMessages((prev) => [...prev, errorMessage]);
      } finally {
        setIsLoading(false);
      }
    },
    [sessionId]
  );

  const clearChat = useCallback(async () => {
    if (sessionId) {
      try {
        await chatService.deleteSession(sessionId);
      } catch (err) {
        console.error('Failed to delete session:', err);
      }
    }

    try {
      const session = await chatService.createSession();
      setSessionId(session.session_id);

      const welcomeMessage: Message = {
        id: 'welcome-reset',
        role: 'assistant',
        content:
          "Hello! 👋 I'm your customer support assistant. How can I help you today?",
        timestamp: new Date(),
      };

      setMessages([welcomeMessage]);
      setError(null);
    } catch (err) {
      console.error('Failed to reset chat:', err);
      setError('Failed to reset chat session.');
    }
  }, [sessionId]);

  return {
    messages,
    sendMessage,
    clearChat,
    isLoading,
    error,
    sessionId,
  };
};