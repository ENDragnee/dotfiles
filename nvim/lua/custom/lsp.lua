-- Runs once nvim-lspconfig has loaded (see custom/plugins.lua), so the server
-- definitions from its lsp/ directory are on the runtimepath.
--
-- NvChad's defaults() sets capabilities/on_init for "*", enables lua_ls and
-- attaches its mappings through an LspAttach autocmd. Servers below must not set
-- on_attach: that would replace nvim-lspconfig's own (e.g. :LspOxlintFixAll).
local paths = require "custom.paths"

-- The starter's configs/lspconfig.lua already calls defaults(); calling it twice
-- would register the LspAttach mappings twice.
if not package.loaded["configs.lspconfig"] then
    require("nvchad.configs.lspconfig").defaults()
end

local config = vim.lsp.config

-- Web / TS (Next.js, NestJS, Solid, Vue, Astro)
-- vue_ls 3.x forwards TypeScript requests to ts_ls, which needs the Vue plugin.
config("ts_ls", {
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
    init_options = {
        -- Used only when the project has no node_modules/typescript of its own.
        tsserver = { fallbackPath = paths.tsserver },
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = paths.vue_typescript_plugin,
                languages = { "vue" },
            },
        },
    },
})
config("html", {
    filetypes = { "html", "ejs", "blade" },
    settings = {
        html = {
            validate = { scripts = false, styles = false },
            format = { enable = false },
        },
    },
})
config("vue_ls", {
    init_options = {
        typescript = { tsdk = paths.tsdk },
    },
})
if paths.typescript_node_modules then
    config("astro", {
        cmd = { "env", "NODE_PATH=" .. paths.typescript_node_modules, "astro-ls", "--stdio" },
        init_options = {
            typescript = { tsdk = paths.tsdk },
        },
    })
end

-- Laravel / PHP
config("intelephense", {
    filetypes = { "php", "blade" },
    settings = {
        intelephense = { files = { maxSize = 5000000 } },
    },
})

-- C / C++ (Rust is handled by rustaceanvim)
local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
}
if paths.clangd_query_driver then
    table.insert(clangd_cmd, "--query-driver=" .. paths.clangd_query_driver)
end
config("clangd", { cmd = clangd_cmd })

-- Prose: harper for style/spelling, ltex for grammar (ltex_extra adds dictionaries)
config("harper_ls", {
    filetypes = { "markdown", "text", "gitcommit" },
    settings = {
        ["harper-ls"] = {
            userDictPath = vim.fn.expand "~/.config/harper/dict.txt",
            linters = {
                SpellCheck = true,
                SpelledNumbers = false,
                AvoidCurses = false,
            },
        },
    },
})
config("ltex_plus", {
    filetypes = { "markdown", "text", "gitcommit", "tex" },
    settings = {
        ltex = {
            language = "en-US",
            -- harper_ls already does spelling; keep ltex to grammar and style.
            disabledRules = { ["en-US"] = { "MORFOLOGIK_RULE_EN_US" } },
        },
    },
})
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ltex_plus" then
            require("ltex_extra").setup { load_langs = { "en-US" } }
        end
    end,
})

local servers = {
    -- Web / TS
    "ts_ls",
    "oxlint",
    "eslint",
    "html",
    "cssls",
    "jsonls",
    "tailwindcss",
    "prismals",
    "vue_ls",
    "astro",
    -- PHP
    "intelephense",
    -- Systems
    "clangd",
    -- Java / Kotlin
    "kotlin_language_server",
    -- Docs / Shell / Nix
    "markdown_oxide",
    "harper_ls",
    "ltex_plus",
    "bashls",
    "nil_ls",
    -- Go / Python
    "gopls",
    "pylsp",
}

-- Only enable servers whose binary exists, so a missing toolchain (e.g. Java or
-- ltex when the Nix extras are off) does not log an error for every buffer.
vim.lsp.enable(vim.tbl_filter(function(name)
    local cmd = (vim.lsp.config[name] or {}).cmd
    return type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1
end, servers))
