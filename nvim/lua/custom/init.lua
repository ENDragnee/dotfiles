-- Entry point. Required from lua/extraConfig.lua under Nix (nix4nvchad) and from
-- init.lua in a plain checkout, after NvChad has loaded.
-- LSP, DAP and treesitter are wired up from their plugin specs in custom/plugins.lua.

require("custom.options")

-- The starter loads its own mappings in vim.schedule; queue ours after it.
vim.schedule(function()
  require("custom.mappings")
end)
