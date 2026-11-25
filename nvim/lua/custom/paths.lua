-- External tool paths. Under Nix (NixOS / nix-darwin) they come from custom/nix.lua,
-- which the Home Manager module generates; in a plain checkout of this config they
-- fall back to Mason packages or whatever is on PATH.
local ok, nix = pcall(require, "custom.nix")
if not ok then
  nix = {}
end

local mason = vim.fn.stdpath("data") .. "/mason/packages"
local mason_debugpy = mason .. "/debugpy/venv/bin/python"

return {
  -- TypeScript 5 (tsserver.js) for ts_ls, vue_ls and astro; nil = use the project's
  tsdk = nix.tsdk,
  tsserver = nix.tsserver,
  typescript_node_modules = nix.typescript_node_modules,
  vue_typescript_plugin = nix.vue_typescript_plugin or (mason .. "/vue-language-server/node_modules/@vue/language-server"),
  clangd_query_driver = nix.clangd_query_driver,
  js_debug = nix.js_debug or "js-debug-adapter",
  lldb_dap = nix.lldb_dap or "lldb-dap",
  -- Python with debugpy, for nvim-dap-python
  python = nix.python or (vim.uv.fs_stat(mason_debugpy) and mason_debugpy) or "python3",
}
