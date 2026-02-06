local map = vim.keymap.set

-- Your normal/insert mode mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-l>", "<Nop>", { silent = true })

map("n", "<A-p>", "<cmd> Telescope project <cr>", { desc = "Projects" })
map("n", "<A-l>", "<cmd> Telescope terms <cr>", { desc = "Toggle hidden terminals" })

local M = {}

M.general = {
    i = {
        ["<C-l>"] = {
            function()
                require("copilot.suggestion").accept_line()
            end,
            "Copilot Accept Line",
            { expr = false, noremap = true, silent = true },
        },
    },
}

return M
