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
                -- Lua
                "lua-language-server",
                "stylua",

                -- Bash
                "bash-language-server",
                "shfmt",
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

    -- SYNTAX HIGHLIGHTING (Fixed & Cleaned)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            -- Protected call to prevent crash if treesitter isn't compiled yet
            local status_ok, configs = pcall(require, "nvim-treesitter.configs")
            if not status_ok then
                return
            end

            configs.setup {
                ensure_installed = {
                    "vim",
                    "lua",
                    "vimdoc",
                    "dart", -- Flutter/Dart
                    "bash", -- Bash scripts
                    "markdown",
                    "markdown_inline",
                    "json",
                },
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
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

            -- Copilot Commands
            vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = "*", range = true })

            vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
                chat.ask(args.args, { selection = select.buffer })
            end, { nargs = "*", range = true })
        end,
        event = "VeryLazy",
    },

    -- PROJECT MANAGEMENT
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
    -- FLUTTER & ANDROID TOOLS
    {
        "akinsho/flutter-tools.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- Optional: Makes the device selector menu look nicer
        },
        config = function()
            require("flutter-tools").setup {
                ui = {
                    border = "rounded",
                    notification_style = "plugin", -- or "native"
                },
                debugger = {
                    enabled = true,
                    run_via_dap = true, -- Enable debugging via nvim-dap
                    register_configurations = function(paths)
                        require("dap").configurations.dart = {
                            {
                                type = "dart",
                                request = "launch",
                                name = "Launch Flutter (Debug)",
                                dartSdkPath = paths.dart_sdk,
                                flutterSdkPath = paths.flutter_sdk,
                                program = "${workspaceFolder}/lib/main.dart",
                                cwd = "${workspaceFolder}",
                                toolArgs = { "-d", "android" }, -- Force Android device if needed
                            },
                        }
                    end,
                },
                -- Android / Emulator Management
                dev_log = {
                    enabled = true,
                    open_cmd = "tabedit", -- Opens logs in a new tab
                },
                lsp = {
                    color = {
                        enabled = true,
                        background = true,
                        virtual_text = false,
                    },
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                    },
                },
            }

            -- Keymaps for Android Management
            local map = vim.keymap.set
            map("n", "<leader>Fd", "<cmd>FlutterDevices<cr>", { desc = "Flutter Devices" })
            map("n", "<leader>Fe", "<cmd>FlutterEmulators<cr>", { desc = "Flutter Emulators" })
            map("n", "<leader>Fr", "<cmd>FlutterReload<cr>", { desc = "Hot Reload" })
            map("n", "<leader>FR", "<cmd>FlutterRestart<cr>", { desc = "Hot Restart" })
            map("n", "<leader>Fmq", "<cmd>FlutterQuit<cr>", { desc = "Quit Flutter" })
            map("n", "<leader>Fl", "<cmd>FlutterLogToggle<cr>", { desc = "Toggle Logs" })
        end,
    },
    {
        "hsanson/vim-android",
        ft = { "java", "kotlin", "xml", "gradle" },
        config = function()
            vim.g.android_sdk_path = os.getenv "ANDROID_HOME" or "/opt/android-sdk"
        end,
    },
}
