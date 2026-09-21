# Contributing to Let's Encrypt Certificate Pipeline

Thank you for your interest in contributing! This document provides guidelines and information for contributors.

## How to Contribute

### 1. Fork the Repository

1. Go to the repository page
2. Click the "Fork" button
3. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/lets-encrypt-ga.git
   cd lets-encrypt-ga
   ```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names:
- `feature/add-support-for-x`
- `fix/issue-with-y`
- `docs/update-readme`

### 3. Make Your Changes

- Follow the existing code style
- Add comments for complex logic
- Update documentation if needed
- Test your changes locally

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add new feature description"
```

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for adding tests
- `chore:` for maintenance tasks

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Create a Pull Request

1. Go to the original repository
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template
5. Submit the PR

## Development Setup

### Prerequisites

- Bash shell
- Git
- certbot (for testing)
- Cloudflare account with API access

### Local Testing

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your test credentials

3. Source the environment:
   ```bash
   source .env
   ```

4. Run the script:
   ```bash
   ./scripts/generate-cert.sh
   ```

### Testing with Mock Credentials

For testing without real Cloudflare credentials:

1. Create a test Cloudflare account
2. Use a test domain you control
3. Never commit real credentials

## Code Style

### Bash Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable `set -euo pipefail` for error handling
- Use meaningful variable names
- Add comments for complex logic
- Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

### YAML Files

- Use 2-space indentation
- Keep lines under 80 characters
- Add comments for complex configurations

### Documentation

- Use clear, concise language
- Include examples where helpful
- Keep README up to date

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to reproduce**: Step-by-step instructions
3. **Expected behavior**: What you expected to happen
4. **Actual behavior**: What actually happened
5. **Environment**: OS, shell, certbot version
6. **Logs**: Any relevant error messages

### Feature Requests

When suggesting features:

1. **Description**: Clear description of the feature
2. **Use case**: Why this feature would be useful
3. **Proposed solution**: How you think it could work
4. **Alternatives**: Any alternative solutions considered

## Security

### Reporting Security Issues

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Email security@yourdomain.com (replace with actual email)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Security Guidelines

- Never commit credentials or secrets
- Use GitHub Secrets for sensitive data
- Rotate API tokens regularly
- Follow least privilege principle

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

If you have questions about contributing:

1. Check existing documentation
2. Search existing issues
3. Open a new issue with the "question" label

Thank you for contributing!