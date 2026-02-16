-- ~/.config/nvim/lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"

-- Helper function to fix the "deprecated" error on Nvim 0.11+
local function setup_server(server_name, config)
    -- Apply NvChad defaults
    config.on_attach = config.on_attach or on_attach
    config.on_init = config.on_init or on_init
    config.capabilities = config.capabilities or capabilities

    if vim.lsp.config then
        -- ✅ New Native API (Nvim 0.11+)
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
    else
        -- ⚠️ Old Plugin API (Fallback)
        lspconfig[server_name].setup(config)
    end
end

require("mason-lspconfig").setup {
    handlers = {
        -- 1. Default Handler (Install everything else automatically)
        function(server_name)
            setup_server(server_name, {})
        end,

        -- 2. GraphQL Specific Setup
        ["graphql"] = function()
            setup_server("graphql", {
                -- Important: Listen to typescript files so gql`...` works
                filetypes = { "graphql", "typescript", "javascript", "typescriptreact" },
            })
        end,

        -- 3. Lua Specific Override
        ["lua_ls"] = function()
            setup_server("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },
}

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
