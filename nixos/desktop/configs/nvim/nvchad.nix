{ pkgs, inputs, ... }:

{
  programs.nvchad = {
    enable = true;

    extraPackages = with pkgs; [
      # PHP / Laravel
      php84
      php84Packages.composer
      nodePackages.intelephense
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
      python313Packages.python-lsp-server
      python313Packages.debugpy

      # Shell / Lua / Nix
      nodePackages.bash-language-server
      stylua
      nil

      # Go
      go
      gopls
      golangci-lint
      go-tools

      #C and C++
      clang
      clang-tools

      # Prisma
      prisma-language-server

      # Utils
      ripgrep
      fd
      wl-clipboard
      lldb
    ];

    extraPlugins = ''
      return {
        { "mg979/vim-visual-multi" },

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

        {
          "nvim-telescope/telescope-project.nvim",
          config = function()
            require("telescope").load_extension("project")
          end,
        },

        { "stevearc/conform.nvim" },

        { "zbirenbaum/copilot.lua" },
        { "CopilotC-Nvim/CopilotChat.nvim", branch = "main" },

        {
          "adalessa/laravel.nvim",
          ft = { "php", "blade" },
        },

        {
          "mattn/emmet-vim",
          ft = { "html", "css", "blade", "ejs" },
        },

        { "carlos-algms/agentic.nvim" },
        { "hakonharnes/img-clip.nvim" },
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
        extension = {
          ejs = "html",
        },
      })

      ------------------------------------------------------------------
      -- SILENCE NOTIFICATIONS
      ------------------------------------------------------------------
      -- This intercepts messages before they are printed and completely
      -- hides the annoying signatureHelp error.
      vim.notify = (function()
        local old_notify = vim.notify
        return function(msg, level, opts)
          if msg and type(msg) == "string" and msg:find("textDocument/signatureHelp is not supported") then
            return
          end
          -- Pass everything else through normally
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
          filetypes = {"html", "ejs"},
          })
        setup_server("cssls")
        setup_server("tailwindcss")
        setup_server("bashls")
        setup_server("nil_ls")
        setup_server("pylsp")
        setup_server("intelephense")
        setup_server("clangd", {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- Use Nix interpolation to point to the actual wrapped binaries
            "--query-driver=${pkgs.stdenv.cc}/bin/cc,${pkgs.stdenv.cc}/bin/gcc,${pkgs.clang}/bin/clang,${pkgs.clang}/bin/clang++"
          },
        })
        setup_server("gopls")
        setup_server("prismals")
        setup_server("ts_ls", {
          filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        })

        setup_server("vue_ls", {
          init_options = {
            typescript = {
              tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
            },
            vue = {
              hybridMode = false,
            },
          },
          filetypes = { "vue" },
        })

        setup_server("astro", {
          init_options = {
            typescript = {
              tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib",
            },
          },
        })

      end)

      ------------------------------------------------------------------
      -- TREESITTER (DO NOT INSTALL PLUGIN HERE IN NVCHAD NIX)
      ------------------------------------------------------------------

      vim.schedule(function()
        local ok, ts = pcall(require, "nvim-treesitter.configs")

        if ok then
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
              "markdown",
              "embedded_template",

              "c",
              "cpp",
              "go",
              "gomod",
              "prisma",
              "tailwindcss"
            },

            highlight = { enable = true },
            indent = { enable = true },
          })
        end
      end)

      ------------------------------------------------------------------
      -- FORMATTER
      ------------------------------------------------------------------

      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          php = { "pint" },
          python = { "black" },
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          vue = { "prettierd" },
          html = { "prettierd" },
          css = { "prettierd" },
          ejs = { "prettierd" },

          c = { "clang_format" },
          cpp = { "clang_format" },
          go = { "gofmt" },

          -- I REMOVED prisma = { "prismals" } HERE.
          -- Because lsp_fallback = true is set below, Conform will automatically
          -- find and use the Prisma Language Server to format without needing it defined.
        },

        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      ------------------------------------------------------------------
      -- MAPPINGS
      ------------------------------------------------------------------
      local map = vim.keymap.set

      -- General
      map("n", ";", ":", { desc = "CMD enter command mode" })
      map("i", "jk", "<ESC>")

      -- Telescope
      map("n", "<A-p>", "<cmd> Telescope project <cr>", { desc = "Projects" })
      map("n", "<A-l>", "<cmd> Telescope terms <cr>", { desc = "Toggle hidden terminals" })

      -- Copilot
      map("i", "<C-/>", function()
        require("copilot.suggestion").accept_line()
      end, { desc = "Copilot Accept Line" })

      -- LSP
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })

      -- DAP
      map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Dap Toggle Breakpoint" })
      map("n", "<leader>dr", function() require("dap").continue() end, { desc = "Dap Start/Continue" })
      map("n", "<leader>di", function() require("dap").step_into() end, { desc = "Dap Step Into" })
      map("n", "<leader>do", function() require("dap").step_over() end, { desc = "Dap Step Over" })
      map("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Dap Terminate" })
      map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })
    '';
  };
}
