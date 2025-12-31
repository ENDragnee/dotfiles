require "nvchad.mappings"
require "custom.mappings"

-- add yours here

local map = vim.keymap.set
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Unmap <C-l> in normal mode to avoid window navigation conflict
map("n", "<C-l>", "<Nop>", { silent = true })

map("i", "<C-l>", function()
    require("copilot.suggestion").accept_line()
end, { expr = false, noremap = true, silent = true, desc = "Copilot Accept Line" })

map("n", "K", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Open diagnostic float" })

map("n", "<leader>gd", vim.lsp.buf.definition)

local copilot_enabled = false
local function toggle_copliot()
    if vim.fn.exists ":Copilot" == false then
        print "Copilot not installed"
        return
    end

    if copilot_enabled == true then
        vim.cmd "Copilot disable"
        copilot_enabled = false
        print "Copilot Disabled"
    else
        vim.cmd "Copilot enable"
        copilot_enabled = true
        print "Copilot Enabled"
    end
end

map("n", "<C-/>", toggle_copliot, { desc = "Copilot Toggle" })
map("n", "<A-/>", "<cmd>: CopilotChatToggle<cr>", { desc = "Copilot Toggle" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
