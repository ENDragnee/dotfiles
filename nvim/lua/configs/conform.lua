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

        go = { "goimports", "golines", "goimports-reviser" },
    },

    -- format_on_save = false,

    -- format_on_save = {
    --     timeout_ms = 200,
    --     lsp_fallback = true,
    -- },

    format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype

        if ft == "php" or ft == "blade" then
            return {
                timeout_ms = 500,
                lsp_fallback = true,
            }
        end
        return {
            timeout_ms = 200,
            lsp_fallback = true,
        }
    end,
}
