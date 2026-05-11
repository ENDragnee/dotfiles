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
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.tailwindcss
      nodePackages.prettier
      prettierd
      eslint_d
      vue-language-server

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
          ft = { "html", "css", "blade" },
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

        setup_server("html")
        setup_server("cssls")
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
            -- CRITICAL: This allows clangd to query the nix-provided gcc/clang for system headers
            "--query-driver=/nix/store/*/*/bin/gcc,/nix/store/*/*/bin/clang,/nix/store/*/*/bin/g++"
          },
        })
        setup_server("gopls")
        setup_server("ts_ls")
        setup_server("prismals")

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
              "json",
              "yaml",
              "python",
              "php",
              "markdown",

              "c",
              "cpp",
              "go",
              "gomod",
              "prisma"
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

          c = { "clang_format" },
          cpp = { "clang_format" },
          go = { "gofmt" },

          prisma = { "prettierd" },
        },
      })
    '';
  };
}
