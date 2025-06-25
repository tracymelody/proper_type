# Contributing to ProperType

Thank you for your interest in contributing to ProperType! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](../../issues)
2. Use the bug report template
3. Include as much detail as possible:
   - macOS version
   - ProperType version
   - Steps to reproduce
   - Expected vs actual behavior
   - Console logs if relevant

### Suggesting Features

1. Check if the feature has already been suggested
2. Use the feature request template
3. Explain the use case and benefits
4. Consider implementation complexity

### Code Contributions

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes following our coding standards
4. **Test** your changes thoroughly
5. **Commit** with clear, descriptive messages
6. **Push** to your fork
7. **Create** a Pull Request

## Development Setup

### Prerequisites

- macOS 10.15+ (for development)
- Xcode Command Line Tools
- OpenAI API key (for testing)

### Building

```bash
git clone https://github.com/your-username/ProperType.git
cd ProperType
chmod +x build.sh
./build.sh
```

### Testing

1. Install the built app to `/Applications/`
2. Configure with your OpenAI API key
3. Test both hotkey and clipboard functionality
4. Verify accessibility permissions work correctly

## Coding Standards

### Swift Style

- Follow Apple's Swift API Design Guidelines
- Use descriptive variable and function names
- Add comments for complex logic
- Keep functions focused and reasonably sized

### Architecture

- Maintain separation of concerns
- Use singleton patterns appropriately
- Handle errors gracefully
- Respect user privacy and security

### Documentation

- Update README.md for user-facing changes
- Add inline documentation for complex code
- Update build scripts if needed

## Testing Guidelines

### Manual Testing

- Test on multiple macOS versions when possible
- Verify accessibility permissions work correctly
- Test with various text types and applications
- Ensure menu bar integration works properly

### API Testing

- Test with valid and invalid API keys
- Test network error handling
- Verify response parsing works correctly
- Test rate limiting scenarios

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Changes have been tested thoroughly
- [ ] Documentation has been updated
- [ ] Commit messages are clear and descriptive

### PR Description

- Explain what changes were made and why
- Reference any related issues
- Include screenshots for UI changes
- Note any breaking changes

### Review Process

1. Automated checks will run on your PR
2. Maintainers will review the code
3. Address any feedback or requested changes
4. Once approved, the PR will be merged

## Getting Help

- Check existing [Issues](../../issues) and [Discussions](../../discussions)
- Ask questions in issue comments
- Join our community discussions

## Recognition

Contributors will be recognized in the project documentation and release notes.

Thank you for helping make ProperType better! 🚀
