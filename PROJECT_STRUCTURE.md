# anki-editor.nvim Project Structure

## File Tree

```
anki-editor.nvim/
│
├── README.md                      # Main documentation
├── PLANO.md                       # Roadmap and detailed architecture (Portuguese)
├── CHANGELOG.md                   # Version history
├── CONTRIBUTING.md                # Contribution guide
├── LICENSE                        # MIT License
├── development.md                 # Development guide
├── PROJECT_STRUCTURE.md           # This file
│
├── Configuration
│   ├── .gitignore                 # Git ignore patterns
│   ├── .editorconfig              # Editor configuration
│   ├── .luarc.json                # Lua LSP configuration
│   ├── .stylua.toml               # StyLua configuration
│   └── .luacheckrc                # Luacheck configuration
│
├── GitHub
│   └── .github/workflows/
│       ├── lint.yml               # CI: Luacheck + StyLua
│       ├── test.yml               # CI: Tests on multiple Neovim versions
│       └── release.yml            # CD: Create releases automatically
│
├── Plugin (Lua)
│   └── lua/anki-editor/
│       ├── init.lua               # Entry point and setup
│       ├── config.lua             # Configuration management
│       ├── anki_connect.lua       # HTTP client for Anki-Connect
│       ├── commands.lua           # Neovim command handlers
│       ├── buffers.lua            # Buffer management
│       ├── ui.lua                 # Selection UI
│       └── utils.lua              # Utility functions
│
├── Plugin (Vimscript)
│   └── plugin/
│       └── anki-editor.vim        # Entry point (autoload)
│
└── Examples
    └── examples/
        ├── init_nvim.lua          # Basic configuration
        ├── lazy_nvim.lua          # lazy.nvim configuration
        └── vim-plug.lua           # vim-plug configuration
```

## Component Descriptions

### Core Plugin (`lua/anki-editor/`)

| File | Responsibility |
|------|----------------|
| `init.lua` | Main setup, command registration, global state |
| `config.lua` | Configuration validation and management |
| `anki_connect.lua` | HTTP client for Anki-Connect API (GET/POST) |
| `commands.lua` | Handlers for `:AnkiEdit`, `:AnkiList`, `:AnkiPing` |
| `buffers.lua` | Creation, management and synchronization of buffers |
| `ui.lua` | Selection UI using `vim.ui.select` |
| `utils.lua` | Helpers (debounce, split, format, etc.) |

### Tooling Configuration

| File | Purpose |
|------|---------|
| `.stylua.toml` | Lua formatting (column width, indentation) |
| `.luacheckrc` | Lua linting (ignore rules, globals) |
| `.luarc.json` | LSP autocomplete/IntelliSense |
| `.editorconfig` | Cross-editor settings (indentation, charset) |
| `.gitignore` | Git ignore patterns |

### CI/CD (GitHub Actions)

| File | Trigger | Actions |
|------|---------|---------|
| `lint.yml` | Push/PR on main/develop | Luacheck + StyLua |
| `test.yml` | Push/PR on main/develop | Test on Neovim 0.9, 0.10, nightly |
| `release.yml` | Tag push (`v*`) | Create Release + ZIP artifact |

### Documentation

| File | Contents |
|------|----------|
| `README.md` | Overview, installation, usage, troubleshooting |
| `PLANO.md` | Full roadmap, architecture, development phases |
| `development.md` | Dev setup, local testing, code style, debug |
| `CONTRIBUTING.md` | How to contribute, commit messages, PR process |
| `CHANGELOG.md` | Version history (Keep a Changelog format) |
| `PROJECT_STRUCTURE.md` | This file |

### Examples

| File | Usage |
|------|-------|
| `init_nvim.lua` | Basic setup with configuration options |
| `lazy_nvim.lua` | Integration with lazy.nvim (plugin manager) |
| `vim-plug.lua` | Integration with vim-plug |

## Data Flow

```
┌─ User Command ─────────────────────────────────────┐
│  :AnkiEdit                                          │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
        ┌─ commands.lua ─────────┐
        │ edit_template()         │
        └────────┬────────────────┘
                 │
                 ▼
        ┌─ anki_connect.lua ──────────────────┐
        │ get_model_names()                   │
        │ (HTTP POST to Anki-Connect)         │
        └────────┬─────────────────────────────┘
                 │
                 ▼
        ┌─ ui.lua ───────────────────┐
        │ select_template()           │
        │ (Cascading selection)       │
        └────────┬────────────────────┘
                 │
                 ▼
        ┌─ anki_connect.lua ──────────────────┐
        │ get_model_templates()               │
        │ get_model_styling()                 │
        └────────┬─────────────────────────────┘
                 │
                 ▼
        ┌─ buffers.lua ──────────────────────┐
        │ create_template_buffers()           │
        │ (3 buffers: Front, Back, Style)     │
        └────────┬─────────────────────────────┘
                 │
                 ▼
    ┌─ User edits content ────┐
    │ :w (save)               │
    └────────┬────────────────┘
             │
             ▼
    ┌─ buffers.lua ──────────────────────┐
    │ handle_buffer_save() [BufWritePost] │
    └────────┬─────────────────────────────┘
             │
             ▼
    ┌─ anki_connect.lua ─────────────────┐
    │ update_model_templates() OR         │
    │ update_model_styling()              │
    │ (HTTP POST to Anki-Connect)         │
    └────────┬─────────────────────────────┘
             │
             ▼
    ┌─ Feedback ────────────────────┐
    │ vim.notify() with status      │
    │ Success or error message      │
    └───────────────────────────────┘
```

## Current Development Phase

### MVP (Current)
- Base plugin structure
- Anki-Connect client
- Buffer management
- Commands and UI (in progress)
- Save synchronization (in progress)

### Post-MVP
- Syntax highlighting
- Autocomplete (nvim-cmp)
- Diagnostics (Lua/LSP)
- Telescope integration
- HTML preview

## Getting Started

### For Users
1. Install Anki and Anki-Connect
2. Install or clone the plugin
3. Configure it in your `init.lua`
4. Use `:AnkiEdit`

### For Developers
1. Read [development.md](./development.md)
2. Clone the repository
3. Set up the local environment
4. Make changes in `lua/anki-editor/`
5. Test with `:AnkiPing` and `:AnkiEdit`
6. Submit a PR

## Project Stats

| Metric | Value |
|--------|-------|
| Primary Language | Lua |
| Secondary Language | Vimscript |
| Minimum Neovim Version | 0.6+ |
| Recommended Version | 0.10+ |
| License | MIT |
| Status | MVP |

## Important Links

- **[Anki-Connect API](https://github.com/FooSoft/anki-connect)** — API specification
- **[Neovim Lua Guide](https://github.com/nanotee/nvim-lua-guide)** — Plugin development
- **[Original anki-editor](https://github.com/Pedro-Bronsveld/anki-editor)** — VSCode version (reference)