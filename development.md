# Development Guide

This guide explains how to develop and test the anki-nvim-editor plugin.

## Prerequisites

- Neovim 0.6+ (0.10+ recommended for better `vim.system` support)
- Anki with Anki-Connect add-on installed and running
- Git
- StyLua and Luacheck (for code quality checks)
- curl (for HTTP requests)

## Project Structure

```
anki-nvim-editor/
├── lua/anki-nvim-editor/          # Main plugin source
│   ├── init.lua                   # Entry point and setup
│   ├── config.lua                 # Configuration management
│   ├── anki_connect.lua           # Anki-Connect client
│   ├── commands.lua               # Command handlers
│   ├── buffers.lua                # Buffer management
│   ├── ui.lua                     # UI selection interface
│   └── utils.lua                  # Utility functions
├── plugin/
│   └── anki-nvim-editor.vim       # Plugin entry (Vimscript)
├── .github/workflows/
│   ├── lint.yml                   # Linting CI
│   ├── test.yml                   # Testing CI
│   └── release.yml                # Release CI
└── ...configuration files
```

## Setting Up Development Environment

### Local Testing

1. Clone the repository:
```bash
git clone https://github.com/limaon/anki-nvim-editor.nvim.git
cd anki-nvim-editor.nvim
```

2. Create a test config for Neovim:
```bash
mkdir -p ~/.config/nvim-test
cat > ~/.config/nvim-test/init.vim << 'EOF'
" Test configuration for anki-nvim-editor
set runtimepath+=/path/to/anki-nvim-editor
set runtimepath+=/path/to/plenary.nvim  " optional

lua require('anki-nvim-editor.nvim').setup({
  anki_connect_url = "http://127.0.0.1:8765",
  timeout_ms = 5000,
})
EOF
```

3. Launch Neovim with test config:
```bash
nvim -u ~/.config/nvim-test/init.vim
```

4. Test the plugin:
```vim
:AnkiPing              " Test connection to Anki-Connect
:AnkiList              " List available models
:AnkiEdit              " Open template editor
```

## Code Quality

### Formatting with StyLua

```bash
# Format all Lua files
stylua lua/ plugin/

# Check formatting without modifying
stylua --check lua/ plugin/
```

### Linting with Luacheck

```bash
# Lint all files
luacheck lua/ --globals vim

# Lint specific file
luacheck lua/anki-nvim-editor/init.lua --globals vim
```

### Configuration Files

- `.stylua.toml` - StyLua formatting rules
- `.luacheckrc` - Luacheck lint rules
- `.luarc.json` - Lua LSP configuration

## Testing

### Manual Testing Checklist

- [ ] Anki is running
- [ ] Anki-Connect add-on is active
- [ ] Run `:AnkiPing` and see successful connection message
- [ ] Run `:AnkiList` and see list of models
- [ ] Run `:AnkiEdit` and select a model/card/side
- [ ] Edit template content
- [ ] Save with `:w`
- [ ] Verify changes appear in Anki
- [ ] Test with multiple buffer opens
- [ ] Test error handling (disconnect Anki, test commands)

### Automated Testing

GitHub Actions runs on every push and PR:

1. **Lint workflow** - Checks code formatting and linting
2. **Test workflow** - Tests plugin loading with multiple Neovim versions
3. **Release workflow** - Creates release on version tags

View results in `.github/workflows/` YAML files.

## Debugging

### Enable Neovim logging

```lua
-- In init.lua or your test config
vim.loglevel = vim.log.levels.DEBUG
```

### Print debug info

```lua
-- In your code
local plugin = require('anki-nvim-editor')
print(vim.inspect(plugin.get_state()))
```

### Test Anki-Connect directly

```bash
# Test modelNames action
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"action":"modelNames","version":6}' \
  http://127.0.0.1:8765
```

## Building and Releasing

### Version Bumping

Update version in:
- `CHANGELOG.md` - Add version entry
- Any version references in README.md

### Creating a Release

1. Ensure all changes are committed
2. Create an annotated tag:
```bash
git tag -a v0.1.0 -m "Version 0.1.0"
git push origin v0.1.0
```

3. GitHub Actions will automatically:
   - Create a GitHub Release
   - Generate a ZIP archive
   - Attach it to the release

The release workflow reads from `CHANGELOG.md`, so make sure it's up to date!

## Adding New Features

When adding a new feature:

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Write code following the style guidelines
3. Run `stylua lua/ plugin/` to format
4. Run `luacheck lua/ --globals vim` to lint
5. Test manually with the checklist above
6. Add entry to `CHANGELOG.md`
7. Commit and push
8. Open a Pull Request

## Common Development Tasks

### Adding a new command

1. Add function to `lua/anki-nvim-editor/commands.lua`
2. Register in `lua/anki-nvim-editor/init.lua` using `vim.api.nvim_create_user_command`
3. Add tests to manual checklist
4. Document in README.md

### Adding Anki-Connect API calls

1. Add function to `lua/anki-nvim-editor/anki_connect.lua`
2. Use the `request` function with proper payload structure
3. Test with `curl` first to validate payload format
4. Document the Anki-Connect action version used

### Modifying buffer behavior

1. Update `lua/anki-nvim-editor/buffers.lua`
2. Test with multiple buffers open
3. Test save/modification detection
4. Test error cases (invalid templates, connection loss)

## Resources

- [Neovim Lua API](https://neovim.io/doc/user/lua.html)
- [Anki-Connect API](https://github.com/FooSoft/anki-connect)
- [anki-editor VSCode extension](https://github.com/Pedro-Bronsveld/anki-editor) - Reference implementation
- [Lua style guide](https://github.com/gpg/lua-style-guide)

## Troubleshooting

### Plugin doesn't load

```vim
:checkhealth
:messages
```

Check if `init.lua` has syntax errors and Neovim can find it in runtimepath.

### Anki-Connect not connecting

1. Verify Anki is running
2. Verify Anki-Connect add-on is installed and enabled
3. Check Anki-Connect settings: `http://127.0.0.1:8765`
4. Test with `:AnkiPing`

### Buffers not updating

- Check that buffer modifications trigger `BufWritePost`
- Verify template metadata is stored correctly in `state.active_templates`
- Check Anki-Connect response for errors