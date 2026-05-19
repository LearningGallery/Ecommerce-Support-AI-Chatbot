from typing import List, Dict, Any


class TextChunker:
    """
    Simple sentence-based chunker for FAQ content.
    """

    def __init__(self, chunk_size: int = 512, chunk_overlap: int = 50):
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap

    def chunk_document(
        self,
        text: str,
        metadata: Dict[str, Any] = None
    ) -> List[Dict[str, Any]]:
        if not text:
            return []

        sentences = text.split('. ')
        chunks = []
        current_chunk = []
        current_length = 0

        for sentence in sentences:
            sentence = sentence.strip()
            if not sentence:
                continue

            sentence_length = len(sentence)

            if current_length + sentence_length > self.chunk_size and current_chunk:
                chunk_text = '. '.join(current_chunk)
                if not chunk_text.endswith('.'):
                    chunk_text += '.'

                chunks.append({
                    'content': chunk_text,
                    'metadata': metadata or {}
                })

                overlap_sentences = current_chunk[-2:] if len(current_chunk) >= 2 else current_chunk
                current_chunk = overlap_sentences + [sentence]
                current_length = sum(len(s) for s in current_chunk)
            else:
                current_chunk.append(sentence)
                current_length += sentence_length

        if current_chunk:
            chunk_text = '. '.join(current_chunk)
            if not chunk_text.endswith('.'):
                chunk_text += '.'

            chunks.append({
                'content': chunk_text,
                'metadata': metadata or {}
            })

        return chunks if chunks else [{'content': text, 'metadata': metadata or {}}]