local map = vim.keymap.set

-- Your normal/insert mode mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-l>", "<Nop>", { silent = true })

map("n", "<A-p>", "<cmd> Telescope project <cr>", { desc = "Projects" })
map("n", "<A-l>", "<cmd> Telescope terms <cr>", { desc = "Toggle hidden terminals" })

-- Copilot Accept Line (Converted)
map("i", "<C-l>", function()
    require("copilot.suggestion").accept_line()
end, { expr = false, noremap = true, silent = true, desc = "Copilot Accept Line" })
map("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
end, { desc = "LSP Code Action" })

-- DAP Mappings (Using Lua API)
map("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
end, { desc = "Dap Toggle Breakpoint" })
map("n", "<leader>dr", function()
    require("dap").continue()
end, { desc = "Dap Start/Continue" })
map("n", "<leader>di", function()
    require("dap").step_into()
end, { desc = "Dap Step Into" })
map("n", "<leader>do", function()
    require("dap").step_over()
end, { desc = "Dap Step Over" })
map("n", "<leader>dt", function()
    require("dap").terminate()
end, { desc = "Dap Terminate" })
map("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
