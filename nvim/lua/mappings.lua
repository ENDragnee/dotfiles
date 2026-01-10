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

local function is_copilot_enabled()
    local clients = vim.lsp.get_clients { name = "copilot" }
    return not vim.tbl_isempty(clients)
end

local function toggle_copliot()
    if vim.fn.exists ":Copilot" == false then
        print "Copilot not installed"
        return
    end

    if is_copilot_enabled() then
        vim.cmd ":Copilot disable"
        print "Copilot is disabled"
    else
        vim.cmd ":Copilot enable"
        print "Copilot is enabled"
    end
end

map("n", "<C-/>", toggle_copliot, { desc = "Copilot Toggle" })
map("n", "<A-/>", "<cmd>: CopilotChatToggle<cr>", { desc = "Copilot Toggle" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
