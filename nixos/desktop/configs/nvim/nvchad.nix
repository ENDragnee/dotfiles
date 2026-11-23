{ pkgs, ... }:

{
  programs.nvchad = {
    enable = true;

    extraPackages = with pkgs; [
      # --- Core Build & Utils ---
      gcc
      tree-sitter
      git
      pkg-config
      luajit
      ripgrep
      fd
      wl-clipboard
      bash-language-server
      stylua
      nil

      # --- Critical: Web / TS (Next.js, Astro, Vue, Solid, NestJS) ---
      typescript
      typescript-language-server
      vscode-langservers-extracted # html, css, json, eslint
      tailwindcss-language-server
      vue-language-server
      astro-language-server
      prisma-language-server
      vscode-js-debug # provides js-debug (pwa-node) for JS/TS DAP
      oxlint
      oxfmt
      prettierd # fallback for astro, blade, markdown, etc.

      # --- Dabbling: C, C++, Rust ---
      rust-analyzer
      clang
      clang-tools # clangd + clang-format
      lldb # provides lldb-dap for C, C++, Rust debugging

      # --- Occasional: Laravel / PHP ---
      php85
      php85Packages.composer
      intelephense
      blade-formatter

      # --- Docs & Markdown ---
      harper
      markdown-oxide
      imagemagick
      luajitPackages.magick

      # --- Rarely Used: Go & Python (minimal; move to direnv flakes if unused) ---
      go
      gopls
      python314Packages.python-lsp-server
      python314Packages.black
      python314Packages.debugpy
    ];

    extraPlugins = ''
      return {
        { "mg979/vim-visual-multi" },

        -- Rust: rustaceanvim handles rust-analyzer + cargo + DAP integration
        {
          "mrcjkb/rustaceanvim",
          ft = { "rust" },
          lazy = false,
          config = function()
            local lsp = require("nvchad.configs.lspconfig")

            vim.g.rustaceanvim = {
              server = {
                on_attach = lsp.on_attach,
                on_init = lsp.on_init,
                capabilities = lsp.capabilities,
                default_settings = {
                  ["rust-analyzer"] = {
                    cargo = { allFeatures = true },
                    check = { command = "clippy" },
                  },
                },
              },
            }
          end,
        },

        -- Formatter: Conform properly hooked inside plugin spec
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

        -- Debugger Adapter Protocol (DAP)
        {
          "mfussenegger/nvim-dap",
          dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap-python",
          },
          config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

            -- Auto open/close DAP UI
            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

            -- JS / TS adapter (Node, NestJS, Next.js) via nixpkgs vscode-js-debug
            dap.adapters["pwa-node"] = {
              type = "server",
              host = "127.0.0.1",
              port = "''${port}",
              executable = {
                command = "${pkgs.vscode-js-debug}/bin/js-debug",
                args = { "''${port}" },
              },
            }

            local js_ts_configs = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch current file",
                program = "''${file}",
                cwd = "''${workspaceFolder}",
                sourceMaps = true,
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach to Node / NestJS / Next.js (port 9229)",
                address = "127.0.0.1",
                port = 9229,
                cwd = "''${workspaceFolder}",
                sourceMaps = true,
                skipFiles = { "<node_internals>/**" },
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach to process (pick PID)",
                processId = require("dap.utils").pick_process,
                cwd = "''${workspaceFolder}",
                sourceMaps = true,
                skipFiles = { "<node_internals>/**" },
              },
            }

            for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
              dap.configurations[lang] = js_ts_configs
            end

            -- C / C++ / Rust adapter via lldb-dap
            dap.adapters.lldb = {
              type = "executable",
              command = "${pkgs.lldb}/bin/lldb-dap",
              name = "lldb",
            }

            local lldb_config = {
              {
                name = "Launch executable",
                type = "lldb",
                request = "launch",
                program = function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "''${workspaceFolder}",
                stopOnEntry = false,
                args = {},
              },
            }

            dap.configurations.c = lldb_config
            dap.configurations.cpp = lldb_config
            dap.configurations.rust = lldb_config

            -- Python adapter
            require("dap-python").setup("${pkgs.python314.withPackages (ps: [ ps.debugpy ])}/bin/python")
          end,
        },

        -- Project manager
        {
          "nvim-telescope/telescope-project.nvim",
          config = function()
            require("telescope").load_extension("project")
          end,
        },

        -- AI: Copilot (inline autocomplete only) + Claude Code
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
          "coder/claudecode.nvim",
          dependencies = { "folke/snacks.nvim" },
          config = true,
          cmd = {
            "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel",
            "ClaudeCodeAdd", "ClaudeCodeSend", "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus", "ClaudeCodeStart", "ClaudeCodeStop",
            "ClaudeCodeOpen", "ClaudeCodeClose", "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny", "ClaudeCodeCloseAllDiffs",
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

        -- Laravel & Web helpers
        { "adalessa/laravel.nvim", ft = { "php", "blade" } },
        { "mattn/emmet-vim", ft = { "html", "css", "blade", "ejs", "javascriptreact", "typescriptreact" } },
        { "EmranMR/tree-sitter-blade", ft = { "blade" } },
        { "virchau13/tree-sitter-astro", ft = { "astro" } },

        -- Markdown & Images
        { "hakonharnes/img-clip.nvim" },
        {
          "3rd/image.nvim",
          lazy = false,
          ft = { "markdown", "vimwiki" },
          build = true,
          opts = {
            backend = "kitty",
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
            heading = {
              sign = true,
              icons = { "   ", "   ", "   ", "   ", "   ", "   " },
            },
          },
        },
      }
    '';

    extraConfig = ''
      vim.g.mapleader = " "

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2

      vim.filetype.add({
        pattern = { [".*%.blade%.php"] = "blade" },
        extension = { ejs = "html" },
      })

      if os.getenv("TERM") == "xterm-256color" then
        vim.env.TERM = "xterm-kitty"
      end

      ------------------------------------------------------------------
      -- SILENCE NOISY NOTIFICATIONS
      ------------------------------------------------------------------
      vim.notify = (function()
        local old_notify = vim.notify
        return function(msg, level, opts)
          if msg and type(msg) == "string" then
            if msg:find("signatureHelp")
               or msg:find("textDocument/signatureHelp is not supported")
               or msg:find("Couldn't find Astro in workspace") then
              return
            end
          end
          old_notify(msg, level, opts)
        end
      end)()

      ------------------------------------------------------------------
      -- LSP
      ------------------------------------------------------------------
      vim.schedule(function()
        local lsp = require("nvchad.configs.lspconfig")

        local function setup_server(server, config)
          config = config or {}
          config.on_attach = config.on_attach or lsp.on_attach
          config.on_init = config.on_init or lsp.on_init
          config.capabilities = config.capabilities or lsp.capabilities

          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        end

        -- Web / TS (Next.js, NestJS, Solid, Vue, Astro)
        setup_server("ts_ls", {
          filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        })
        setup_server("oxlint")
        setup_server("cssls")
        setup_server("tailwindcss")
        setup_server("prismals")
        setup_server("html", {
          filetypes = { "html", "ejs", "blade" },
          settings = {
            html = {
              validate = { scripts = false, styles = false },
              format = { enable = false },
            },
          },
        })
        setup_server("vue_ls", {
          filetypes = { "vue" },
          init_options = {
            typescript = { tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib" },
            vue = { hybridMode = false },
          },
        })
        setup_server("astro", {
          cmd = {
            "env",
            "NODE_PATH=${pkgs.typescript}/lib/node_modules",
            "astro-ls",
            "--stdio",
          },
          filetypes = { "astro" },
          init_options = {
            typescript = { tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib" },
          },
        })

        -- Laravel / PHP
        setup_server("intelephense", {
          filetypes = { "php", "blade" },
          files = { maxSize = 5000000 },
        })

        -- Systems (C/C++; Rust is handled by rustaceanvim)
        setup_server("clangd", {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=${pkgs.stdenv.cc}/bin/cc,${pkgs.stdenv.cc}/bin/gcc,${pkgs.clang}/bin/clang,${pkgs.clang}/bin/clang++",
          },
        })

        -- Docs / Shell / Nix
        setup_server("markdown_oxide")
        setup_server("harper_ls", {
          filetypes = { "markdown", "text", "gitcommit" },
          settings = {
            ["harper-ls"] = {
              userDictPath = "~/.config/harper/dict.txt",
              linters = {
                spell_check = true,
                spelled_numbers = false,
                avoid_curses = false,
              },
            },
          },
        })
        setup_server("bashls")
        setup_server("nil_ls")

        -- Rarely Used (Go / Python)
        setup_server("gopls")
        setup_server("pylsp")
      end)

      ------------------------------------------------------------------
      -- TREESITTER
      ------------------------------------------------------------------
      vim.schedule(function()
        local ok, ts = pcall(require, "nvim-treesitter.configs")
        if ok then
          local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
          parser_config.blade = {
            install_info = {
              url = "https://github.com/EmranMR/tree-sitter-blade",
              files = { "src/parser.c" },
              branch = "main",
            },
            filetype = "blade",
          }

          ts.setup({
            ensure_installed = {
              "lua", "vim", "bash", "nix",
              "html", "css", "javascript", "typescript", "tsx", "vue", "astro",
              "json", "yaml", "prisma", "sql", "dockerfile",
              "c", "cpp", "rust",
              "php", "php_only",
              "go", "gomod", "python",
              "markdown",
            },
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = { "blade" },
            },
            indent = { enable = true },
          })
        end
      end)

      ------------------------------------------------------------------
      -- MAPPINGS
      ------------------------------------------------------------------
      local map = vim.keymap.set

      map("n", ";", ":", { desc = "CMD enter command mode" })
      map("i", "jk", "<ESC>")

      map("n", "<A-p>", "<cmd>Telescope project<cr>", { desc = "Projects" })
      map("n", "<A-l>", "<cmd>Telescope terms<cr>", { desc = "Toggle hidden terminals" })

      map("n", "<leader>k", <cmd> tab new | term <cr>, { desc = "Open a terminal in a new vim tab" })

      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      map("n", "<leader>fm", function() require("conform").format({ async = true }) end, { desc = "Format buffer" })
      map("n", "<leader>lx", "<cmd>LspOxlintFixAll<cr>", { desc = "Oxlint fix all" })
      map("n", "<leader>k", "<cmd>tab new | term<cr>", { desc = "Open terminal in new tab" })

      -- DAP
      map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
      map("n", "<leader>dr", function() require("dap").continue() end, { desc = "DAP Start/Continue" })
      map("n", "<leader>di", function() require("dap").step_into() end, { desc = "DAP Step Into" })
      map("n", "<leader>do", function() require("dap").step_over() end, { desc = "DAP Step Over" })
      map("n", "<leader>dt", function() require("dap").terminate() end, { desc = "DAP Terminate" })
      map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "DAP Toggle UI" })

      map("n", "<leader>rr", "<cmd>NvimTreeRefresh<cr>", { desc = "Refresh nvim tree" })
      map("n", "<leader>gi", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic detail" })
      map("n", "<leader>gl", vim.diagnostic.setloclist, { silent = true, desc = "List all diagnostics" })
    '';
  };
}
