-- Standalone-only specs. Shared plugins live in lua/custom/plugins.lua; under Nix
-- these tools come from the Home Manager module instead of Mason.
return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    -- :MasonInstallAll installs everything below.
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                -- Lua / Shell / Nix
                "lua-language-server",
                "stylua",
                "bash-language-server",
                "nil",

                -- Web / TS
                "typescript-language-server",
                "vue-language-server",
                "astro-language-server",
                "tailwindcss-language-server",
                "css-lsp",
                "html-lsp",
                "json-lsp",
                "eslint-lsp",
                "oxlint",
                "prisma-language-server",
                "prettierd",
                "js-debug-adapter",

                -- PHP / Laravel
                "intelephense",
                "blade-formatter",
                "pint",

                -- C, C++, Rust
                "clangd",
                "clang-format",
                "rust-analyzer",

                -- Java / Kotlin
                "kotlin-language-server",
                "ktfmt",

                -- Docs & prose
                "markdown-oxide",
                "harper-ls",
                "ltex-ls-plus",

                -- Go & Python
                "gopls",
                "python-lsp-server",
                "black",
                "debugpy",
            },
        },
    },
}
