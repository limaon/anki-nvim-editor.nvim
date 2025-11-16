# Changelog

All notable changes to the anki-editor.nvim project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup with GitHub Actions CI/CD
- Basic plugin structure (MVP)
- Anki-Connect client for HTTP communication
- Buffer management for template editing
- Command system (`:AnkiEdit`, `:AnkiList`, `:AnkiRefresh`, `:AnkiPing`)
- UI selection interface using `vim.ui.select`
- Auto-save functionality with debouncing

### Planned
- Syntax highlighting for Anki templates
- LSP-based autocomplete for fields and filters
- Real-time diagnostics and validation
- Telescope integration for enhanced UI
- Extended documentation and examples

## [0.1.0] - TBD

### Added
- MVP release with core functionality
- Basic template editing for Front, Back, and CSS
- Integration with Anki-Connect
- Configuration system
- Error handling and user notifications

---

## How to document changes

When adding changes, add them to the `[Unreleased]` section using one or more of:
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for any security fixes

When creating a release, move the `[Unreleased]` section to a new version heading.

