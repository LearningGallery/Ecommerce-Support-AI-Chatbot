export interface SourceCitation {
  content: string;
  source: string;
  score: number;
  metadata?: Record<string, unknown>;
}

export interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
  sources?: SourceCitation[];
}

export interface ChatRequest {
  message: string;
  session_id?: string;
  user_id?: string;
  use_rag?: boolean;
  include_history?: boolean;
}

export interface ChatResponse {
  session_id: string;
  message: string;
  sources?: SourceCitation[];
  timestamp: string;
  metadata?: Record<string, unknown>;
}

export interface Session {
  session_id: string;
  user_id: string;
  message_count: number;
  created_at: string;
  updated_at: string;
}