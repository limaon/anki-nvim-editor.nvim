-- Luacheck configuration
globals = { "vim" }
max_line_length = 100
unused_args = false
unused_secondaries = false

exclude_files = {
  ".git",
  ".github",
  "node_modules",
}

ignore = {
  "631", -- line too long (stylua handles this)
}

