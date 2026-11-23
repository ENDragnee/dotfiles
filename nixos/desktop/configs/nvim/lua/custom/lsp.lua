-- Runs once nvim-lspconfig has loaded (see custom/plugins.lua), so the server
-- definitions from its lsp/ directory are on the runtimepath.
--
-- NvChad's defaults() sets capabilities/on_init for "*", enables lua_ls and
-- attaches its mappings through an LspAttach autocmd. Servers below must not set
-- on_attach: that would replace nvim-lspconfig's own (e.g. :LspOxlintFixAll).
local nix = require("custom.nix")

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
    tsserver = { fallbackPath = nix.tsserver },
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = nix.vue_typescript_plugin,
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
    typescript = { tsdk = nix.tsdk },
  },
})
config("astro", {
  cmd = { "env", "NODE_PATH=" .. nix.typescript_node_modules, "astro-ls", "--stdio" },
  init_options = {
    typescript = { tsdk = nix.tsdk },
  },
})

-- Laravel / PHP
config("intelephense", {
  filetypes = { "php", "blade" },
  settings = {
    intelephense = { files = { maxSize = 5000000 } },
  },
})

-- C / C++ (Rust is handled by rustaceanvim)
config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--query-driver=" .. nix.clangd_query_driver,
  },
})

-- Docs
config("harper_ls", {
  filetypes = { "markdown", "text", "gitcommit" },
  settings = {
    ["harper-ls"] = {
      userDictPath = vim.fn.expand("~/.config/harper/dict.txt"),
      linters = {
        SpellCheck = true,
        SpelledNumbers = false,
        AvoidCurses = false,
      },
    },
  },
})

vim.lsp.enable({
  -- Web / TS
  "ts_ls",
  "oxlint",
  "html",
  "cssls",
  "tailwindcss",
  "prismals",
  "vue_ls",
  "astro",
  -- PHP
  "intelephense",
  -- Systems
  "clangd",
  -- Docs / Shell / Nix
  "markdown_oxide",
  "harper_ls",
  "bashls",
  "nil_ls",
  -- Go / Python
  "gopls",
  "pylsp",
})
