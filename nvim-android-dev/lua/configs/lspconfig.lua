local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = { "bashls", "dartls" }

-- Helper function to handle the API change between Nvim 0.10 and 0.11
local function setup(server, opts)
    -- Ensure default NvChad opts are applied
    opts.on_attach = opts.on_attach or on_attach
    opts.on_init = opts.on_init or on_init
    opts.capabilities = opts.capabilities or capabilities

    if vim.lsp.config then
        -- ✅ Neovim 0.11+ (New Native API)
        -- Defines the config and enables the server
        vim.lsp.config(server, opts)
        vim.lsp.enable(server)
    else
        -- ⚠️ Neovim 0.10 (Old Plugin API)
        -- Fallback if you downgrade Neovim later
        require("lspconfig")[server].setup(opts)
    end
end

-- 1. Setup standard servers
for _, lsp in ipairs(servers) do
    setup(lsp, {})
end

-- 2. Setup Lua with custom settings
setup("lua_ls", {
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
