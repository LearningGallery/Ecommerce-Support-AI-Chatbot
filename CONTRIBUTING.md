# Contributing to E-Commerce Customer Support AI Chatbot

First off, thank you for considering contributing to this project! 🎉

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if applicable**
- **Include your environment details** (OS, AWS region, versions)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any alternatives you've considered**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the existing code style**
3. **Write clear commit messages** using conventional commits:
   - `feat:` new feature
   - `fix:` bug fix
   - `docs:` documentation changes
   - `style:` formatting, missing semicolons, etc.
   - `refactor:` code refactoring
   - `test:` adding tests
   - `chore:` maintenance tasks

4. **Update documentation** if needed
5. **Add tests** for new functionality
6. **Ensure all tests pass**
7. **Update CHANGELOG.md**

## Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/ecommerce-support-chatbot.git
cd ecommerce-support-chatbot

# Create a feature branch
git checkout -b feature/amazing-feature

# Install dependencies
cd backend && pip install -r requirements.txt
cd ../frontend && npm install

# Make your changes
# ...

# Run tests
cd backend && pytest
cd ../frontend && npm test

# Commit your changes
git commit -m "feat: add amazing feature"

# Push to your fork
git push origin feature/amazing-feature
```

## Code Style Guidelines

### Python (Backend)
- Follow PEP 8
- Use type hints
- Maximum line length: 100 characters
- Use meaningful variable names
- Add docstrings to functions and classes
- Use `black` for formatting
- Use `pylint` for linting

```python
def calculate_relevance_score(query: str, document: str) -> float:
    """
    Calculate relevance score between query and document.
    
    Args:
        query: User search query
        document: Document content
        
    Returns:
        Relevance score between 0 and 1
    """
    # Implementation
    pass
```

### TypeScript (Frontend)
- Follow ESLint configuration
- Use functional components
- Use TypeScript types (avoid `any`)
- Maximum line length: 100 characters
- Use meaningful component names
- Add JSDoc comments for complex functions

```typescript
interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

const ChatWindow: React.FC = () => {
  // Implementation
};
```

### Terraform (Infrastructure)
- Use consistent naming conventions
- Add descriptions to variables
- Use modules for reusable components
- Tag all resources appropriately
- Format code with `terraform fmt`

```hcl
variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}
```

## Testing Guidelines

### Backend Tests
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test
pytest tests/test_chat_service.py::test_process_chat
```

### Frontend Tests
```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test
npm test -- ChatWindow.test.tsx
```

## Documentation Guidelines

- Keep documentation up to date
- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Update README.md for major changes
- Create ADRs for architectural decisions

## Review Process

1. All submissions require review
2. Changes must pass all automated checks
3. Documentation must be updated
4. At least one approval required
5. No merge conflicts

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community discussions
- Contact the maintainers

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- README.md (Contributors section)
- GitHub insights

Thank you for your contributions! 🙏