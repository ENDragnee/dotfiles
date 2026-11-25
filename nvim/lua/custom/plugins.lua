-- Plugin specs shared by every setup: imported from init.lua (standalone) or from
-- nix4nvchad's plugins/init-2.lua (NixOS / nix-darwin).
local paths = require "custom.paths"

return {
    {
        "mg979/vim-visual-multi",
        event = "VeryLazy",
        init = function()
            -- VM's default <C-n> would replace NvChad's nvim-tree toggle. gb = "add cursor
            -- at next match", as in VSCode's Vim mode; then n / N / q inside VM.
            vim.g.VM_maps = {
                ["Find Under"] = "gb",
                ["Find Subword Under"] = "gb",
            }
        end,
    },

    ------------------------------------------------------------------
    -- LSP / Treesitter (override the NvChad + starter specs)
    ------------------------------------------------------------------
    {
        -- Not `config`: under Nix, lazy also imports plugins/init-1.lua (the starter) on its own
        -- after this file, so the starter's config would win. Hook in once it has loaded.
        "neovim/nvim-lspconfig",
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyLoad",
                callback = function(args)
                    if args.data == "nvim-lspconfig" then
                        require "custom.lsp"
                        return true
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        -- nvim-treesitter `main` branch: setup() only takes install_dir, highlighting is
        -- started by NvChad's FileType autocmd. Under Nix the plugin, queries and all
        -- parsers come from nixpkgs (on the runtimepath via custom/options.lua);
        -- standalone, the parsers below are downloaded and compiled.
        dir = paths.treesitter_plugin,
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").blade = {
                        install_info = {
                            url = "https://github.com/EmranMR/tree-sitter-blade",
                            branch = "main",
                            queries = "queries",
                        },
                    }
                end,
            })
        end,
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "bash",
                "nix",
                "html",
                "css",
                "javascript",
                "typescript",
                "tsx",
                "vue",
                "astro",
                "json",
                "yaml",
                "prisma",
                "sql",
                "dockerfile",
                "c",
                "cpp",
                "rust",
                "php",
                "php_only",
                "blade",
                "go",
                "gomod",
                "python",
                "markdown",
                "markdown_inline",
            })
        end,
        config = function(_, opts)
            local ts = require "nvim-treesitter"
            if paths.treesitter_runtime then
                -- setup() prepends install_dir to the runtimepath; the default
                -- (stdpath("data")/site) would put stale runtime-built parsers first.
                ts.setup { install_dir = paths.treesitter_runtime }
            else
                ts.setup()
                ts.install(opts.ensure_installed)
            end
        end,
    },

    -- Rust: rustaceanvim handles rust-analyzer + cargo + DAP integration (must not be lazy-loaded)
    {
        "mrcjkb/rustaceanvim",
        lazy = false,
        init = function()
            vim.g.rustaceanvim = function()
                return {
                    server = {
                        capabilities = require("nvchad.configs.lspconfig").capabilities,
                        default_settings = {
                            ["rust-analyzer"] = {
                                cargo = { allFeatures = true },
                                check = { command = "clippy" },
                            },
                        },
                    },
                }
            end
        end,
    },

    ------------------------------------------------------------------
    -- Formatting
    ------------------------------------------------------------------
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                -- Web / TS: prefer oxfmt, fall back to prettierd
                javascript = { "oxfmt", "prettierd", stop_after_first = true },
                javascriptreact = { "oxfmt", "prettierd", stop_after_first = true },
                typescript = { "oxfmt", "prettierd", stop_after_first = true },
                typescriptreact = { "oxfmt", "prettierd", stop_after_first = true },
                vue = { "oxfmt", "prettierd", stop_after_first = true },
                json = { "oxfmt", "prettierd", stop_after_first = true },
                jsonc = { "oxfmt", "prettierd", stop_after_first = true },
                css = { "oxfmt", "prettierd", stop_after_first = true },
                html = { "oxfmt", "prettierd", stop_after_first = true },

                -- Frameworks / Templating
                astro = { "prettierd" },
                ejs = { "prettierd" },
                php = { "pint" }, -- uses project-local ./vendor/bin/pint
                blade = { "blade-formatter" },

                -- Systems / Other
                c = { "clang-format" },
                cpp = { "clang-format" },
                rust = { "rustfmt" },
                go = { "gofmt" },
                python = { "black" },
                lua = { "stylua" },
                markdown = { "prettierd", "injected" },
            },
            formatters = {
                ["blade-formatter"] = {
                    command = "blade-formatter",
                    args = { "--stdin" },
                },
            },
            format_on_save = {
                timeout_ms = 4000,
                lsp_format = "fallback",
            },
        },
    },

    ------------------------------------------------------------------
    -- Debugging (loaded on the first require("dap") from the <leader>d maps)
    ------------------------------------------------------------------
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap-python",
        },
        config = function()
            require "custom.dap"
        end,
    },

    ------------------------------------------------------------------
    -- Navigation
    ------------------------------------------------------------------
    {
        "nvim-telescope/telescope-project.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        keys = {
            { "<A-p>", "<cmd>Telescope project<cr>", desc = "Projects" },
        },
        config = function()
            require("telescope").load_extension "project"
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = function(_, opts)
            opts.view = opts.view or {}
            opts.view.number = true
            opts.view.relativenumber = true
        end,
    },

    ------------------------------------------------------------------
    -- AI: Copilot (inline autocomplete + chat), Claude Code, agentic (ACP)
    ------------------------------------------------------------------
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<M-l>",
                    accept_word = "<M-w>",
                    accept_line = "<C-/>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
        },
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
        cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle", "CopilotChatPrompts", "CopilotChatModels" },
        keys = {
            { "<A-/>", "<cmd>CopilotChatToggle<cr>", mode = { "n", "v" }, desc = "Copilot Chat toggle" },
        },
        opts = {},
    },
    {
        "carlos-algms/agentic.nvim",
        opts = {},
        keys = {
            {
                "<C-\\>",
                function()
                    require("agentic").toggle()
                end,
                mode = { "n", "v", "i" },
                desc = "Agentic chat toggle",
            },
            {
                "<C-'>",
                function()
                    require("agentic").add_selection_or_file_to_context()
                end,
                mode = { "n", "v" },
                desc = "Agentic add file/selection",
            },
            {
                "<C-,>",
                function()
                    require("agentic").new_session()
                end,
                mode = { "n", "v", "i" },
                desc = "Agentic new session",
            },
        },
    },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
        cmd = {
            "ClaudeCode",
            "ClaudeCodeFocus",
            "ClaudeCodeSelectModel",
            "ClaudeCodeAdd",
            "ClaudeCodeSend",
            "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus",
            "ClaudeCodeStart",
            "ClaudeCodeStop",
            "ClaudeCodeOpen",
            "ClaudeCodeClose",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeCloseAllDiffs",
        },
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
            },
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },

    ------------------------------------------------------------------
    -- Laravel & Web helpers
    ------------------------------------------------------------------
    { "adalessa/laravel.nvim", ft = { "php", "blade" } },
    { "mattn/emmet-vim", ft = { "html", "css", "blade", "ejs", "javascriptreact", "typescriptreact" } },

    ------------------------------------------------------------------
    -- Prose
    ------------------------------------------------------------------
    -- Code actions + dictionaries for ltex_plus (set up from custom/lsp.lua on attach)
    { "barreiroleo/ltex_extra.nvim" },

    ------------------------------------------------------------------
    -- Markdown & Images
    ------------------------------------------------------------------
    { "hakonharnes/img-clip.nvim", cmd = { "PasteImage" } },
    {
        "3rd/image.nvim",
        ft = { "markdown", "vimwiki" },
        opts = {
            backend = "kitty",
            processor = "magick_cli", -- the magick luarock is not on Nix's Lua path
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = false,
                    filetypes = { "markdown", "vimwiki" },
                },
            },
            max_width = 100,
            max_height = 12,
            max_width_window_percentage = math.huge,
            max_height_window_percentage = math.huge,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "numic" },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" },
        opts = {
            heading = { sign = true },
        },
    },
}
