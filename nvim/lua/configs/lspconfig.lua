-- ~/.config/nvim/lua/configs/lspconfig.lua

local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

require("mason-lspconfig").setup {
    handlers = {
        -- default handler
        function(server_name)
            lspconfig[server_name].setup {
                on_attach = on_attach,
                on_init = on_init,
                capabilities = capabilities,
            }
        end,

        -- lua specific override
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup {
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },

                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
    },
}

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
