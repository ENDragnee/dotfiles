-- Additions to nvchad.mappings and the starter mappings (";" and "jk" live there).
-- <leader>ca, <leader>fm and gd are already NvChad defaults.
local map = vim.keymap.set

map("n", "<A-l>", "<cmd>Telescope terms<cr>", { desc = "Toggle hidden terminals" })
map("n", "<leader>k", "<cmd>tab new | term<cr>", { desc = "Open terminal in new tab" })

map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<leader>lx", "<cmd>LspOxlintFixAll<cr>", { desc = "Oxlint fix all" })
map("n", "<leader>gi", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic detail" })
map("n", "<leader>gl", vim.diagnostic.setloclist, { silent = true, desc = "List all diagnostics" })

map("n", "<leader>rr", "<cmd>NvimTreeRefresh<cr>", { desc = "Refresh nvim tree" })

-- DAP
local function dap(fn)
  return function()
    require("dap")[fn]()
  end
end

map("n", "<leader>db", dap("toggle_breakpoint"), { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dr", dap("continue"), { desc = "DAP Start/Continue" })
map("n", "<leader>di", dap("step_into"), { desc = "DAP Step Into" })
map("n", "<leader>do", dap("step_over"), { desc = "DAP Step Over" })
map("n", "<leader>dt", dap("terminate"), { desc = "DAP Terminate" })
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "DAP Toggle UI" })
