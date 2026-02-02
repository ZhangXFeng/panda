# CLAUDE.md - AI Assistant Guide for Panda

This file provides guidance for AI assistants working with the Panda repository.

## Project Overview

Panda is a new project currently in its initial development phase. This document will be updated as the project structure evolves.

**Repository**: ZhangXFeng/panda

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd panda

# Install dependencies (update when package manager is chosen)
# npm install  # for Node.js
# pip install -r requirements.txt  # for Python
# cargo build  # for Rust
```

## Project Structure

```
panda/
├── CLAUDE.md          # This file - AI assistant guidance
├── README.md          # Project documentation (to be created)
├── src/               # Source code (to be created)
├── tests/             # Test files (to be created)
└── docs/              # Documentation (to be created)
```

> **Note**: Update this structure as the project develops.

## Development Workflow

### Branch Naming Convention

- Feature branches: `feature/<description>`
- Bug fixes: `fix/<description>`
- Documentation: `docs/<description>`
- AI-assisted work: `claude/<description>-<session-id>`

### Commit Message Format

Use conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Pull Request Process

1. Create a feature branch from main
2. Make changes and commit with clear messages
3. Push to remote and create a pull request
4. Ensure all checks pass before requesting review

## Code Conventions

### General Guidelines

1. **Readability**: Write clear, self-documenting code
2. **Simplicity**: Prefer simple solutions over complex ones
3. **Testing**: Write tests for new functionality
4. **Documentation**: Document public APIs and complex logic

### File Organization

- Keep files focused and single-purpose
- Group related functionality together
- Use consistent naming conventions across the project

## AI Assistant Guidelines

When working with this repository:

### Do

- Read and understand existing code before making changes
- Follow established patterns and conventions
- Write tests for new functionality
- Keep changes focused and minimal
- Use clear, descriptive commit messages

### Don't

- Make changes without understanding context
- Over-engineer solutions
- Add unnecessary dependencies
- Skip tests for new features
- Commit sensitive information (API keys, credentials)

### Common Tasks

1. **Adding a feature**: Create in `src/`, add tests in `tests/`
2. **Fixing a bug**: Understand root cause, fix, and add regression test
3. **Refactoring**: Ensure tests pass before and after changes
4. **Documentation**: Update relevant docs alongside code changes

## Testing

```bash
# Run all tests (update with actual test command)
# npm test
# pytest
# cargo test
```

### Test Coverage

- Aim for meaningful test coverage
- Focus on critical paths and edge cases
- Integration tests for key workflows

## Environment Setup

### Required Tools

- Git
- (Add language-specific tools as project develops)

### Environment Variables

Document any required environment variables here:

```bash
# Example:
# export PANDA_ENV=development
# export PANDA_DEBUG=true
```

## Troubleshooting

### Common Issues

1. **Build failures**: Ensure all dependencies are installed
2. **Test failures**: Check for environment-specific issues
3. **Merge conflicts**: Rebase on latest main branch

## Resources

- [Project Documentation](./docs/) (to be created)
- [Contributing Guidelines](./CONTRIBUTING.md) (to be created)

---

*Last updated: 2026-02-02*
*This document should be updated as the project evolves.*
