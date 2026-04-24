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
        "williamboman/mason.nvim",
        opts = {
            cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
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
                "prettierd", -- Formatter
                "eslint_d", -- JS/TS Linter
                "eslint-lsp", -- JS/TS Linter
                "typescript-language-server",

                -- Other tools
                "stylua", -- Lua formatter
                "bashls",
                "clangd",
                "pylsp",
                "graphql",
                "prisma-language-server",
                "jinja_lsp",
                "dockerls",
                "dotls",
                "jdtl",
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason-lspconfig").setup()
            require "configs.lspconfig"
        end,
    },

    -- SYNTAX HIGHLIGHTING with Treesitter
    -- SYNTAX HIGHLIGHTING with Treesitter (main branch architecture)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false, -- Important: The main branch does NOT support lazy-loading
        config = function()
            local ts = require "nvim-treesitter"

            -- 1. Setup Custom Blade Parser
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").blade = {
                        install_info = {
                            url = "https://github.com/EmranMR/tree-sitter-blade",
                            files = { "src/parser.c", "src/scanner.cc" },
                            branch = "main",
                        },
                    }
                end,
            })
            vim.treesitter.language.register("blade", "blade")

            -- 2. Automatically install languages
            local parsers = {
                "vim",
                "lua",
                "vimdoc",
                "html",
                "css",
                "javascript",
                "php",
                "java",
                "graphql",
                "typescript",
                "python",
            }
            local function isnt_installed(lang)
                return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
            end
            local to_install = vim.tbl_filter(isnt_installed, parsers)
            if #to_install > 0 then
                ts.install(to_install)
            end

            -- 3. Start Highlighting and Indentation natively
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    -- Safely start treesitter
                    local ok = pcall(vim.treesitter.start, args.buf)

                    if ok then
                        -- Enable treesitter indentation
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                        -- Fallback to regex highlighting for blade (replaces additional_vim_regex_highlighting)
                        if vim.bo[args.buf].filetype == "blade" then
                            vim.bo[args.buf].syntax = "on"
                        end
                    end
                end,
            })
        end,
    },

    -- COPILOT SETUP
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            filetypes = {
                yaml = false,
                markdown = false,
                help = false,
                agentic = false, -- Tell Copilot to ignore the Agentic chat buffer
                ["agentic-prompt"] = false,
            },
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
    {
        "carlos-algms/agentic.nvim",

        dependencies = {
            {
                "hakonharnes/img-clip.nvim",
            },
        },
        opts = {
            -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp"
            provider = "gemini-acp", -- setting the name here is all you need to get started
            acp_providers = {
                ["gemini-acp"] = {
                    command = "gemini",
                    args = { "--experimental-acp", "--model", "gemini-3-flash-preview" },
                    env = {
                        GEMINI_API_KEY = os.getenv "NEOVIM_GEMINI_API_KEY",
                    },
                },
                ["claude-agent-acp"] = {
                    env = {
                        ANTHROPIC_API_KEY = os.getenv "ANTHROPIC_API_KEY",
                    },
                },

                -- Example of how override the ACP command to suit your installation, if needed
                ["codex-acp"] = {
                    command = "~/.local/bin/codex-acp",
                },

                ["goose-ollama"] = {
                    command = "/home/end/.local/bin/goose",
                    args = { "acp", "--with-builtin", "developer" },
                    env = {
                        OLLAMA_HOST = "http://localhost:11434",
                        GOOSE_TELEMETRY = "false",
                        GOOSE_PROVIDER = "ollama",
                        GOOSE_MODEL = "llama3.2:latest",

                        -- 1. FORCE THE PATHS (Stops the /home(end) hallucination)
                        HOME = "/home/end",
                        USER = "end",

                        -- 2. FORCE THE WORKING DIRECTORY
                        -- This tells Goose exactly where Neovim is standing
                        GOOSE_WORKING_DIR = vim.fn.getcwd(),

                        -- 3. ENABLE "SESSION" PERSISTENCE
                        -- This makes it act more like the standalone CLI
                        GOOSE_SESSION_ID = "nvim-session",

                        OLLAMA_KEEP_ALIVE = "-1",
                    },
                },

                -- Add any new ACP-compatible provider — the name and command are up to you
                ["my-cool-acp"] = {
                    name = "My Cool ACP",
                    command = "cool-acp",
                    args = { "--mode", "acp" },
                    env = {
                        COOL_API_KEY = os.getenv "COOL_API_KEY",
                    },
                },
            },
        },

        -- these are just suggested keymaps; customize as desired
        keys = {
            {
                "<C-`>",
                function()
                    require("agentic").toggle()
                end,
                mode = { "n", "v", "i" },
                desc = "Toggle Agentic Chat",
            },
            {
                "<C-,>",
                function()
                    require("agentic").new_session()
                end,
                mode = { "n", "v", "i" },
                desc = "New Agentic Session",
            },
            {
                "<A-i>r", -- ai Restore
                function()
                    require("agentic").restore_session()
                end,
                desc = "Agentic Restore session",
                silent = true,
                mode = { "n", "v", "i" },
            },
            {
                "<leader>ac",
                function()
                    require("agentic").toggle()
                end,
                mode = { "n", "v" },
                desc = "Toggle Agentic Chat",
            },
            {
                "<leader>aa",
                function()
                    require("agentic").add_selection_or_file_to_context()
                end,
                mode = { "n", "v" },
                desc = "Add file or selection to Agentic to Context",
            },
            {
                "<leader>an",
                function()
                    require("agentic").new_session()
                end,
                mode = { "n", "v" },
                desc = "New Agentic Session",
            },
            {
                "<leader>ar", -- ai Restore
                function()
                    require("agentic").restore_session()
                end,
                desc = "Agentic Restore session",
                silent = true,
                mode = { "n", "v" },
            },
            {
                "<leader>ad", -- ai Diagnostics
                function()
                    require("agentic").add_current_line_diagnostics()
                end,
                desc = "Add current line diagnostic to Agentic",
                mode = { "n" },
            },
            {
                "<leader>aD", -- ai all Diagnostics
                function()
                    require("agentic").add_buffer_diagnostics()
                end,
                desc = "Add all buffer diagnostics to Agentic",
                mode = { "n" },
            },
        },
    },
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require "dap"
            -- Define codelldb adapter (assumes Mason installation)
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
                    args = { "--port", "${port}" },
                },
            }
            -- Configure C debugging to prompt for executable path
            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    args = function()
                        local args_str = vim.fn.input "Arguments: "
                        return vim.split(args_str, " +")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
            dap.configurations.cpp = dap.configurations.c

            dap.adapters.python = {
                type = "executable",
                command = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python",
                args = { "-m", "debugpy.adapter" },
            }
            dap.configurations.python = {
                {
                    type = "python", -- Matches the adapter name above
                    request = "launch",
                    name = "Launch file",
                    program = "${file}", -- Runs the current file
                    pythonPath = function()
                        -- Automatically use virtual environments if they exist
                        local cwd = vim.fn.getcwd()
                        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                            return cwd .. "/venv/bin/python"
                        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                            return cwd .. "/.venv/bin/python"
                        else
                            return "/usr/bin/python" -- Arch Linux default system python
                        end
                    end,
                },
            }
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap, dapui = require "dap", require "dapui"
            dapui.setup()
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
        opts = {
            ensure_installed = { "codelldb", "python" },
            handlers = {}, -- automatically sets up codelldb for you
        },
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
        config = function()
            -- Point dap-python to the debugpy installation provided by Mason
            local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
            local debugpy_path = mason_path .. "packages/debugpy/venv/bin/python"

            require("dap-python").setup(debugpy_path)
        end,
    },
}
