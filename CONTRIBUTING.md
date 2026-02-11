# Contributing to UChat

Thank you for your interest in contributing to UChat! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a positive environment
- Report unacceptable behavior to the maintainers

## Getting Started

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR_USERNAME/UChat.git
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Run `flutter analyze` to check for issues
- Follow the existing project structure

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add message pagination support
fix: resolve token refresh race condition
docs: update OAuth flow documentation
test: add unit tests for chat service
```

### Testing Requirements

- Add unit tests for new business logic
- Add widget tests for new UI components
- Ensure all tests pass before submitting PR
- Maintain or improve code coverage

### Documentation

- Update README.md if adding user-facing features
- Update ARCHITECTURE.md for architectural changes
- Add inline comments for complex logic
- Update CHANGELOG.md

### Security

- Never commit sensitive data (tokens, keys, credentials)
- Follow security best practices in SECURITY.md
- Report security vulnerabilities privately to security@usafe.in
- Do not log sensitive information

## Pull Request Process

1. **Before submitting**
   - Ensure all tests pass
   - Run `flutter analyze` with no errors
   - Update documentation
   - Add entry to CHANGELOG.md

2. **PR Description**
   - Describe what changes were made and why
   - Reference related issues
   - Include screenshots for UI changes
   - List any breaking changes

3. **Review Process**
   - Maintainers will review your PR
   - Address feedback and requested changes
   - Be patient and respectful during review

4. **After Approval**
   - Maintainers will merge your PR
   - Delete your feature branch

## Project Structure

```
lib/
├── core/           # Core infrastructure
├── features/       # Feature modules
├── models/         # Data models
└── services/       # Shared services
```

### Adding a New Feature

1. Create feature directory:
   ```
   lib/features/my_feature/
   ├── models/
   ├── providers/
   └── presentation/
       ├── pages/
       └── widgets/
   ```

2. Implement using clean architecture
3. Add appropriate tests
4. Document the feature

## Areas for Contribution

### High Priority
- Real-time messaging implementation
- Message pagination
- Typing indicators
- Message status indicators
- Push notifications setup

### Medium Priority
- Group chat support
- Media sharing
- User search
- Contact management
- Profile editing

### Low Priority
- UI/UX improvements
- Performance optimizations
- Additional tests
- Documentation improvements

## Questions?

- Open an issue for discussion
- Check existing issues and PRs
- Review documentation
- Ask maintainers

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in the app (optional)

Thank you for contributing to UChat! 🎉
