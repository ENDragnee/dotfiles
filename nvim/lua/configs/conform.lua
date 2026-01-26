-- ~/.config/nvim/lua/configs/conform.lua

return {
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },

        -- Web
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        astro = { "prettierd" },

        -- Laravel / PHP
        php = { "pint" },
        blade = { "pint" },

        haskell = { "ormolu" },
        nix = { "alejandra" },
    },

    -- Custom formatter definitions
    formatters = {
        pint = {
            command = "pint",
            args = {}, -- no --stdin
            stdin = false, -- run on files
        },
    },
    -- format_on_save = false,

    format_on_save = {
        timeout_ms = 200, -- increase timeout for large files
        lsp_fallback = true,
    },
}
