import { apiClient } from './apiClient';
import { ChatRequest, ChatResponse, Session } from '../types/chat.types';

export class ChatService {
  async sendMessage(request: ChatRequest): Promise<ChatResponse> {
    return apiClient.post<ChatResponse>('/chat', request);
  }

  async createSession(user_id: string = 'anonymous'): Promise<Session> {
    return apiClient.post<Session>('/sessions', { user_id });
  }

  async getSession(session_id: string): Promise<Session> {
    return apiClient.get<Session>(`/sessions/${session_id}`);
  }

  async deleteSession(session_id: string): Promise<void> {
    return apiClient.delete<void>(`/sessions/${session_id}`);
  }

  async healthCheck(): Promise<{ status: string; services: Record<string, string> }> {
    return apiClient.get('/health');
  }
}

export const chatService = new ChatService();