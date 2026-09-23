{ pkgs, lib, ... }:

{
  programs.nvchad = {
    enable = true;

    extraPackages =
      with pkgs;
      [
        # Compilation and general build tools
        gcc
        tree-sitter
        git
        pkg-config
        luajit

        # Java Runtime
        jdk

        # Documentation Qol, Grammar & Spellchecker LSP
        harper
        ltex-ls-plus
        imagemagick
        luajitPackages.magick

        # Markdown
        markdown-oxide

        # PHP / Laravel
        php85
        php85Packages.composer
        intelephense
        blade-formatter

        # Web / Frontend
        typescript-language-server
        typescript
        vscode-langservers-extracted
        tailwindcss
        prettier
        prettierd
        eslint_d
        vue-language-server
        astro-language-server
        tailwindcss-language-server

        # Python
        black
        python314Packages.python-lsp-server
        python314Packages.debugpy

        # Shell / Lua / Nix
        bash-language-server
        stylua
        nil

        # Go
        go
        gopls
        golangci-lint
        go-tools

        # C / C++
        clang
        clang-tools

        # Prisma
        prisma-language-server

        # Utils
        ripgrep
        fd
        lldb

        # Kotlin
        kotlin-language-server
        ktfmt
      ]
      ++ (
        with pkgs;
        lib.optionals stdenv.isLinux [
          wl-clipboard
        ]
      );

    extraPlugins = ''
      return {
        { "mg979/vim-visual-multi" },

        -- Debugger Adapter Protocol configs
        { "mfussenegger/nvim-dap" },
        {
          "rcarriga/nvim-dap-ui",
          dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
          },
          config = function()
            require("dapui").setup()
          end,
        },
        { "mfussenegger/nvim-dap-python" },

        -- Project manager using telescope
        {
          "nvim-telescope/telescope-project.nvim",
          config = function()
            require("telescope").load_extension("project")
          end,
        },

        -- Conform: The default formater for nvchad
        { "stevearc/conform.nvim" },

        -- Copilot integration
        { "zbirenbaum/copilot.lua" },
        { "CopilotC-Nvim/CopilotChat.nvim", branch = "main" },

        -- Laravel project into a first-class editing experience
        {
          "adalessa/laravel.nvim",
          ft = { "php", "blade" },
        },

        -- Emmet plugin for web dev related suggestions
        {
          "mattn/emmet-vim",
          ft = { "html", "css", "blade", "ejs" },
        },

        -- A harness to integrate AI into neovim
        { "carlos-algms/agentic.nvim" },
        -- A plugin that enables image copy in neovim
        { "hakonharnes/img-clip.nvim" },

        {
          "virchau13/tree-sitter-astro",
          ft = { "astro" },
        },

        -- Plugin that allows inline image previews
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

        -- Multi-size Heading Fonts & Full Markdown Rendering
        {
          "MeanderingProgrammer/render-markdown.nvim",
          dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
          ft = { "markdown" },
          opts = {
            heading = {
              -- Enables proportional heading font scaling sizes if supported by your terminal font
              sign = true,
              icons = { "   ", "   ", "   ", "   ", "   ", "   " },
            },
          },
          config = function(_, opts)
            require("render-markdown").setup(opts)
          end,
        },

        -- Companion extension to handle LTeX Code Actions / Custom Dictionaries
        {
          "barreiroleo/ltex_extra.nvim",
          ft = { "markdown", "text", "gitcommit", "tex" },
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
        pattern = {
          [".*%.blade%.php"] = "blade",
        },
        extension = {
          ejs = "html",
        },
      })

      if os.getenv("TERM") == "xterm-256color" then
        vim.env.TERM = "xterm-kitty"
      end

      ------------------------------------------------------------------
      -- SILENCE NOTIFICATIONS
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

        setup_server("html", {
          filetypes = { "html", "ejs", "blade" },
          settings = {
            html = {
              validate = { scripts = false, styles = false },
              format = { enable = false },
            },
          },
        })

        setup_server("intelephense", {
          filetypes = { "php", "blade" },
          files = {
            maxSize = 5000000,
          },
        })

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

        setup_server("ltex_plus", {
          filetypes = { "markdown", "text", "gitcommit", "tex" },
          settings = {
            ltex = {
              language = "en-US", -- Set your preferred dictionary variant
            },
          },
          on_attach = function(client, bufnr)
            -- Activates the client-extension shim for dictionary writing operations
            require("ltex_extra").setup({
              load_langs = { "en-US" },
              init_check = true,
              path = vim.fn.stdpath("config") .. "/spell",
            })
          end,
        })

        setup_server("cssls")
        setup_server("tailwindcss")
        setup_server("bashls")
        setup_server("nil_ls")
        setup_server("pylsp")
        setup_server("clangd", {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=${pkgs.stdenv.cc}/bin/cc,${pkgs.stdenv.cc}/bin/gcc,${pkgs.clang}/bin/clang,${pkgs.clang}/bin/clang++"
          },
        })
        setup_server("gopls")
        setup_server("prismals")
        setup_server("ts_ls", {
          filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        })

        setup_server("vue_ls", {
          filetypes = { "vue" },
          init_options = {
            typescript = {
              tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
            },
            vue = {
              hybridMode = false,
            },
          },
        })

        setup_server("astro", {
          cmd = {
            "env",
            "NODE_PATH=" .. "${pkgs.typescript}/lib/node_modules",
            "astro-ls",
            "--stdio",
          },
          filetypes = { "astro" },
          init_options = {
            typescript = {
              tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
            },
          },
        })
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
              "lua",
              "vim",
              "bash",
              "html",
              "css",
              "javascript",
              "typescript",
              "tsx",
              "vue",
              "astro",
              "json",
              "yaml",
              "python",
              "php",
              "php_only",
              "markdown",
              "c",
              "cpp",
              "go",
              "gomod",
              "prisma",
              "tailwindcss",
              "markdown"
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
      -- FORMATTER (CONFORM)
      ------------------------------------------------------------------
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          php = { "pint" },
          blade = { "blade-formatter" },
          python = { "black" },
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          vue = { "prettierd" },
          html = { "prettierd" },
          css = { "prettierd" },
          ejs = { "prettierd" },
          json = { "prettierd" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          go = { "gofmt" },
          astro = { "prettier" },
          markdown = { "prettierd", "injected" }
        },
        formatters = {
          ["blade-formatter"] = {
            command = "blade-formatter",
            args = { "--stdin" },
          },
        },
        format_on_save = {
          timeout_ms = 4000, -- Raised from 500 to allow blade-formatter to finish
          lsp_fallback = true,
        },
      })
      vim.o.shell = "/run/current-system/sw/bin/fish"

      ------------------------------------------------------------------
      -- MAPPINGS
      ------------------------------------------------------------------
      local map = vim.keymap.set

      map("n", ";", ":", { desc = "CMD enter command mode" })
      map("i", "jk", "<ESC>")

      map("n", "<A-p>", "<cmd> Telescope project <cr>", { desc = "Projects" })
      map("n", "<A-l>", "<cmd> Telescope terms <cr>", { desc = "Toggle hidden terminals" })
      map("n", "<leader>tl", "<cmd> Telescope terms <cr>", { desc = "Toggle hidden terminals" })
      map({ "n", "t" }, "<leader>ti", function()
        require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
      end, { desc = "Toggle floating terminal" })

      map("i", "<C-/>", function()
        require("copilot.suggestion").accept_line()
      end, { desc = "Copilot Accept Line" })

      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })

      map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Dap Toggle Breakpoint" })
      map("n", "<leader>dr", function() require("dap").continue() end, { desc = "Dap Start/Continue" })
      map("n", "<leader>di", function() require("dap").step_into() end, { desc = "Dap Step Into" })
      map("n", "<leader>do", function() require("dap").step_over() end, { desc = "Dap Step Over" })
      map("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Dap Terminate" })
      map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })
      map("n", "<leader>rr", "<cmd> NvimTreeRefresh <cr>", {desc = "Refresh nvim tree"} )
      map("n", "<leader>gi", vim.diagnostic.open_float, { silent = true, desc = "Show grammar error detail" })
      map("n", "<leader>gl", vim.diagnostic.setloclist, { silent = true, desc = "List all file diagnostics" })
    '';
  };
}
