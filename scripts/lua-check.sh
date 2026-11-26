#!/usr/bin/env bash
# Run lua-language-server diagnostics over this Neovim config.
# Read-only: --check only analyses files, it never edits them.
set -euo pipefail

config_root="$HOME/.config/nvim"
lsp="${LUA_LSP:-$HOME/.local/share/nvim/mason/bin/lua-language-server}"

if [[ ! -x "$lsp" ]]; then
  echo "lua-language-server not found at: $lsp" >&2
  exit 1
fi

exec "$lsp" \
  --check="$config_root" \
  --configpath="$config_root/.luarc.json" \
  --checklevel=Warning \
  --check_format=pretty
