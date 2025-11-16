# Contributing to anki-nvim-editor

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/anki-nvim-editor.git`
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Test your changes locally
6. Commit your changes with clear messages
7. Push to your fork: `git push origin feature/your-feature`
8. Open a pull request against the main repository

## Code Style

The project uses:
- **StyLua** for Lua formatting (config: `.stylua.toml`)
- **Luacheck** for linting (config: `.luacheckrc`)

### Before submitting a PR:

```bash
# Format code with StyLua
stylua lua/ plugin/

# Check code with Luacheck
luacheck lua/ --globals vim
```

## Commit Messages

Use clear, descriptive commit messages:

```
feat: add syntax highlighting support
fix: correct buffer save logic
docs: update README with examples
refactor: simplify connection handling
test: add tests for buffer creation
```

## Pull Request Process

1. Ensure all tests pass locally
2. Update documentation if needed
3. Add an entry to `CHANGELOG.md` under `[Unreleased]`
4. Reference any related issues: `Fixes #123`
5. Keep PR focused on a single feature or fix
6. Provide clear description of changes

## Reporting Issues

When reporting bugs, please include:
- Neovim version (`nvim --version`)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Relevant configuration

## Testing

Before submitting a PR, test with:

```bash
# Manual testing
nvim --noplugin -u init.vim
:set runtimepath+=/path/to/anki-nvim-editor

# Run the :AnkiPing command to verify Anki-Connect connection
:AnkiPing
```

## Documentation

- Update `README.md` for user-facing changes
- Update `PLANO.md` for architecture/design changes
- Add inline comments for complex logic
- Keep documentation in English and Portuguese where applicable

## Questions?

Feel free to open an issue or discussion for questions. We're here to help!

