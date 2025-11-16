.PHONY: help format lint test install-tools clean nvim nvim-test

# Colors for output
BOLD := \033[1m
RESET := \033[0m
GREEN := \033[32m
BLUE := \033[34m

help:
	@echo "$(BOLD)anki-nvim-editor - Development Tasks$(RESET)"
	@echo ""
	@echo "$(BLUE)Available targets:$(RESET)"
	@echo "  $(GREEN)format$(RESET)          - Format code with StyLua"
	@echo "  $(GREEN)lint$(RESET)            - Lint code with Luacheck"
	@echo "  $(GREEN)check$(RESET)           - Format check (without modifying)"
	@echo "  $(GREEN)test$(RESET)            - Run tests (placeholder)"
	@echo "  $(GREEN)install-tools$(RESET)   - Install StyLua and Luacheck"
	@echo "  $(GREEN)nvim$(RESET)            - Launch Neovim with plugin"
	@echo "  $(GREEN)nvim-test$(RESET)       - Launch Neovim with test config"
	@echo "  $(GREEN)clean$(RESET)           - Clean generated files"
	@echo "  $(GREEN)help$(RESET)            - Show this help message"
	@echo ""
	@echo "$(BLUE)Examples:$(RESET)"
	@echo "  make format       # Format all Lua files"
	@echo "  make lint         # Check code quality"
	@echo "  make nvim-test    # Test the plugin locally"

format:
	@echo "$(BOLD)Formatting code with StyLua...$(RESET)"
	@command -v stylua >/dev/null 2>&1 || { echo "StyLua not found. Run 'make install-tools'"; exit 1; }
	stylua lua/ plugin/
	@echo "$(GREEN)✓ Formatting complete$(RESET)"

lint:
	@echo "$(BOLD)Linting code with Luacheck...$(RESET)"
	@command -v luacheck >/dev/null 2>&1 || { echo "Luacheck not found. Run 'make install-tools'"; exit 1; }
	luacheck lua/ --globals vim
	@echo "$(GREEN)✓ Linting complete$(RESET)"

check:
	@echo "$(BOLD)Checking format with StyLua...$(RESET)"
	@command -v stylua >/dev/null 2>&1 || { echo "StyLua not found. Run 'make install-tools'"; exit 1; }
	stylua --check lua/ plugin/
	@echo "$(GREEN)✓ Format check complete$(RESET)"

test:
	@echo "$(BOLD)Running tests...$(RESET)"
	@echo "$(BLUE)Note: Tests not yet implemented$(RESET)"
	@echo "See development.md for manual testing procedures"

install-tools:
	@echo "$(BOLD)Installing development tools...$(RESET)"
	@echo "Installing StyLua..."
	@mkdir -p ~/.local/bin
	@curl -L https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-0.20.0-linux.zip -o /tmp/stylua.zip 2>/dev/null && \
		unzip -q /tmp/stylua.zip -d ~/.local/bin && \
		chmod +x ~/.local/bin/stylua && \
		rm /tmp/stylua.zip && \
		echo "$(GREEN)✓ StyLua installed$(RESET)" || echo "Failed to install StyLua"
	@echo "Installing Luacheck..."
	@command -v apt-get >/dev/null 2>&1 && sudo apt-get install -y luacheck >/dev/null 2>&1 && echo "$(GREEN)✓ Luacheck installed$(RESET)" || \
		(echo "Please install luacheck manually (apt-get install luacheck or via your package manager)")

nvim:
	@echo "$(BOLD)Launching Neovim with plugin...$(RESET)"
	@echo "$(BLUE)Note: Make sure Anki and Anki-Connect are running$(RESET)"
	nvim -u NONE -i NONE \
		-c "set runtimepath+=$(PWD)" \
		-c "lua require('anki-nvim-editor').setup()"

nvim-test:
	@echo "$(BOLD)Launching Neovim with test configuration...$(RESET)"
	@echo "$(BLUE)Note: Make sure Anki and Anki-Connect are running$(RESET)"
	@mkdir -p ~/.config/nvim-test
	@cat > ~/.config/nvim-test/init.lua << 'EOF'
set runtimepath+=$(PWD)
lua require('anki-nvim-editor').setup({
  anki_connect_url = "http://127.0.0.1:8765",
  timeout_ms = 5000,
})
EOF
	nvim -u ~/.config/nvim-test/init.lua

clean:
	@echo "$(BOLD)Cleaning generated files...$(RESET)"
	@find . -name "*.swp" -o -name "*.swo" -o -name "*~" | xargs rm -f 2>/dev/null || true
	@rm -rf ~/.config/nvim-test 2>/dev/null || true
	@echo "$(GREEN)✓ Clean complete$(RESET)"

.PHONY: all
all: check lint
	@echo "$(GREEN)✓ All checks passed$(RESET)"

