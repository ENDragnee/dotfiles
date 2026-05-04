-- ~/.config/nvim/lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- Helper to apply NvChad defaults using the new 0.11 syntax
local function setup_server(server_name, config)
    config.on_attach = config.on_attach or on_attach
    config.on_init = config.on_init or on_init
    config.capabilities = config.capabilities or capabilities

    -- NEW 0.11 SYNTAX: Assign directly to vim.lsp.config
    vim.lsp.config[server_name] = config
end

require("mason-lspconfig").setup {
    handlers = {
        -- 1. Default Handler
        function(server_name)
            setup_server(server_name, {})
        end,

        -- 2. Restrict HTMX
        ["htmx"] = function()
            setup_server("htmx", { filetypes = { "html" } })
        end,

        -- 3. TypeScript / Vue (Modernized)
        ["ts_ls"] = function()
            local mason_registry = require "mason-registry"
            local vue_path = mason_registry.get_package("vue-language-server"):get_install_path()
                .. "/node_modules/@vue/language-server"

            setup_server("ts_ls", {
                init_options = {
                    plugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = vue_path,
                            languages = { "vue" },
                        },
                    },
                },
                filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
            })
        end,

        -- 4. Lua (Modernized)
        ["lua_ls"] = function()
            setup_server("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })
        end,
    },
}

-- ==========================================
-- 6. Clangd Setup (The NixOS Fix)
-- ==========================================
setup_server("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--query-driver=/nix/store/*/*/bin/gcc,/nix/store/*/*/bin/g++",
    },
    -- Force it to look for C files
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
})

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
