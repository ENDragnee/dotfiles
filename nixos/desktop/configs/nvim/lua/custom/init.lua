-- Entry point, required from lua/extraConfig.lua after NvChad has loaded.
-- LSP, DAP and treesitter are wired up from their plugin specs in custom/plugins.lua.

require("custom.options")

-- The starter loads its own mappings in vim.schedule; queue ours after it.
vim.schedule(function()
  require("custom.mappings")
end)
