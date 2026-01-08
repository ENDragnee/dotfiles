return {
    {
        "mg979/vim-visual-multi",
    },
    {
        "mfussenegger/nvim-dap",
    },

    -- CORE: LSP, FORMATTING, MASON
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        opts = require "configs.conform",
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                -- PHP / Laravel
                "intelephense", -- PHP LSP
                "pint", -- PHP/Laravel Formatter
                "blade-formatter", -- Blade Formatter
                "laravel-ls", -- ✅ Laravel Language Server (replaces blade-ls)
                "black",

                -- Web Development
                "cssls", -- CSS LSP
                "html", -- HTML LSP
                "tailwindcss-language-server", -- TailwindCSS LSP
                "prettier", -- Formatter
                "eslint_d", -- JS/TS Linter
                "eslint-lsp", -- JS/TS Linter
                "typescript-language-server",

                -- Other tools
                "stylua", -- Lua formatter
                "bashls",
                "clangd",
                "pylsp",
                "graphql",
                "prismals",
                "jinja_lsp",
                "dockerls",
                "dotls",
                "jdtl",
            },
        },
    },

    -- SYNTAX HIGHLIGHTING with Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "vim",
                "lua",
                "vimdoc",
                "html",
                "css",
                "javascript",
                "php",
                "blade",
                "java",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "blade" },
            },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)

            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.blade = {
                install_info = {
                    url = "https://github.com/EmranMR/tree-sitter-blade",
                    files = { "src/parser.c", "src/scanner.cc" },
                    branch = "main",
                },
                filetype = "blade",
            }
        end,
    },

    -- COPILOT SETUP
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<C-]>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-}>",
                },
            },
            panel = { enabled = true },
        },
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            debug = false,
            show_help = true,
            window = {
                layout = "float",
                relative = "cursor",
                width = 0.8,
                height = 0.6,
            },
            auto_follow_cursor = false,
        },
        config = function(_, opts)
            local chat = require "CopilotChat"
            local select = require "CopilotChat.select"
            opts.selection = function(source)
                source = source or {}
                source.buf = source.buf or vim.api.nvim_get_current_buf()
                local visual = select.visual(source)
                if visual and #visual > 0 then
                    return visual
                end
                return select.buffer(source)
            end
            chat.setup(opts)
            vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = "*", range = true })
            vim.api.nvim_create_user_command("CopilotChatInline", function(args)
                chat.ask(args.args, {
                    selection = select.visual,
                    window = {
                        layout = "float",
                        relative = "cursor",
                        width = 1,
                        height = 0.4,
                        row = 1,
                    },
                })
            end, { nargs = "*", range = true })
            vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
                chat.ask(args.args, { selection = select.buffer })
            end, { nargs = "*", range = true })
        end,
        keys = {
            {
                "<leader>ccq",
                ":lua require('CopilotChat').ask(vim.fn.input('Quick Chat: '))<CR>",
                desc = "CopilotChat - Quick chat",
            },
            {
                "<leader>ccv",
                "<cmd>CopilotChatVisual<CR>",
                mode = { "n", "v" },
                desc = "CopilotChat - Visual selection chat",
            },
            { "<leader>ccb", "<cmd>CopilotChatBuffer<space>", mode = { "n" }, desc = "CopilotChat - Buffer chat" },
            { "<leader>cce", ":CopilotChatExplain<CR>", mode = "v", desc = "Explain selection" },
            { "<leader>ccf", ":CopilotChatFix<CR>", mode = "v", desc = "Fix selection" },
            {
                "<leader>cci",
                function()
                    require("CopilotChat").ask_inline "Fix this error and rewrite"
                end,
                mode = { "v" },
                desc = "Copilot Inline Fix",
            },
        },
        event = "VeryLazy",
    },

    -- LARAVEL & BLADE SPECIFIC PLUGINS
    {
        "adalessa/laravel.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-neotest/nvim-nio",
        },
        ft = { "php", "blade" },
        config = function()
            require("laravel").setup()
        end,
    },
    {
        "mattn/emmet-vim",
        ft = { "html", "css", "blade" },
        config = function()
            vim.g.user_emmet_settings = {
                blade = { extends = "html" },
            }
        end,
    },
    {
        "charludo/projectmgr.nvim",
        lazy = false,
    },
    {
        "nvim-telescope/telescope-project.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension "project"
        end,
    },
}
