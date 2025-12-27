-- ~/.config/nvim/lua/configs/lspconfig.lua

require("nvchad.configs.lspconfig").defaults()

local servers = {
    -- PHP / Laravel
    "intelephense",
    "laravel_ls",

    -- Web
    "cssls",
    "tailwindcss",
    "html",
    "eslint",
    "ts_ls",

    -- Other
    "bashls",
    "clangd",
    "pylsp",
    "graphql",
    "prismals",
    "jinja_lsp",
    "dockerls",
    "dotls",
    "jdtls",
    "qmlls",
    "rnix",
    "docker_compose_language_service",
}

vim.lsp.enable(servers)

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
