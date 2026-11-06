{ pkgs, lib, ... }:

{
  programs.nvchad = {
    enable = true;

    extraPackages =
      with pkgs;
      [
        # Core
        fish
        gcc
        git
        pkg-config
        luajit
        tree-sitter
        ripgrep
        fd

        # Debugging
        lldb
        python314Packages.debugpy

        # Lua / Nix / Shell
        stylua
        nil
        bash-language-server

        # Web
        typescript
        typescript-language-server
        vscode-langservers-extracted # html, css, json, eslint
        tailwindcss
        tailwindcss-language-server
        vue-language-server
        astro-language-server
        prisma-language-server
        prettier
        prettierd
        eslint_d

        # PHP / Laravel
        php85
        php85Packages.composer
        intelephense
        blade-formatter

        # Python
        python314Packages.python-lsp-server
        black

        # Go
        go
        gopls
        golangci-lint
        go-tools

        # C / C++
        clang
        clang-tools

        # Java / Kotlin
        jdk # ltex-ls-plus needs it too
        kotlin-language-server
        ktfmt

        # Prose: grammar + spelling
        harper
        ltex-ls-plus

        # Markdown: rendering, math, images
        markdown-oxide
        python3Packages.pylatexenc # latex2text
        texliveMedium # pdflatex, dvisvgm
        poppler-utils # pdftoppm
        imagemagick
        luajitPackages.magick
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.wl-clipboard ];

    extraPlugins = ''
      return {
        ----------------------------------------------------------------
        -- LSP
        ----------------------------------------------------------------
        {
          "neovim/nvim-lspconfig",
          config = function()
            -- NvChad defaults: capabilities, keymaps, diagnostics, lua_ls
            require("nvchad.configs.lspconfig").defaults()

            vim.lsp.config("html", {
              filetypes = { "html", "blade" },
              settings = {
                html = {
                  validate = { scripts = false, styles = false },
                  format = { enable = false },
                },
              },
            })

            vim.lsp.config("intelephense", {
              filetypes = { "php", "blade" },
              settings = { intelephense = { files = { maxSize = 5000000 } } },
            })

            vim.lsp.config("harper_ls", {
              filetypes = { "markdown", "text", "gitcommit" },
              settings = {
                ["harper-ls"] = {
                  userDictPath = vim.fn.expand("~/.config/harper/dict.txt"),
                  linters = {
                    spell_check = true,
                    spelled_numbers = false,
                    avoid_curses = false,
                  },
                },
              },
            })

            vim.lsp.config("ltex_plus", {
              filetypes = { "markdown", "text", "gitcommit", "tex" },
              settings = { ltex = { language = "en-US" } },
              on_attach = function()
                pcall(function()
                  require("ltex_extra").setup({ load_langs = { "en-US" } })
                end)
              end,
            })

            vim.lsp.enable({
              -- Web
              "html", "cssls", "jsonls", "eslint", "ts_ls",
              "tailwindcss", "astro", "prismals",
              -- PHP
              "intelephense",
              -- Languages
              "pylsp", "gopls", "clangd", "kotlin_language_server",
              -- Shell / Nix
              "bashls", "nil_ls",
              -- Prose / Markdown
              "markdown_oxide", "harper_ls", "ltex_plus",
            })
          end,
        },

        -- Code actions + dictionaries for ltex
        {
          "barreiroleo/ltex_extra.nvim",
          ft = { "markdown", "text", "gitcommit", "tex" },
        },

        -- Formatter (NvChad default)
        { "stevearc/conform.nvim" },

        ----------------------------------------------------------------
        -- Debugging
        ----------------------------------------------------------------
        { "mfussenegger/nvim-dap" },
        { "mfussenegger/nvim-dap-python" },
        {
          "rcarriga/nvim-dap-ui",
          dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
          config = function()
            require("dapui").setup()
          end,
        },

        ----------------------------------------------------------------
        -- Editing / Navigation
        ----------------------------------------------------------------
        { "mg979/vim-visual-multi" },
        {
          "nvim-telescope/telescope-project.nvim",
          config = function()
            require("telescope").load_extension("project")
          end,
        },

        ----------------------------------------------------------------
        -- AI
        ----------------------------------------------------------------
        { "zbirenbaum/copilot.lua" },
        { "CopilotC-Nvim/CopilotChat.nvim", branch = "main" },
        { "carlos-algms/agentic.nvim" },

        ----------------------------------------------------------------
        -- Web / PHP
        ----------------------------------------------------------------
        { "adalessa/laravel.nvim", ft = { "php", "blade" } },
        { "mattn/emmet-vim", ft = { "html", "css", "blade" } },
        { "virchau13/tree-sitter-astro", ft = { "astro" } },

        ----------------------------------------------------------------
        -- Markdown
        ----------------------------------------------------------------
        -- Paste images from clipboard
        { "hakonharnes/img-clip.nvim" },

        -- Inline images (kitty)
        {
          "3rd/image.nvim",
          lazy = false,
          build = true,
          opts = {
            backend = "kitty",
            processor = "magick_cli",
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

        -- Headings, tables, math
        {
          "MeanderingProgrammer/render-markdown.nvim",
          ft = { "markdown" },
          dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
          },
          opts = {
            heading = {
              sign = true,
              icons = { "   ", "   ", "   ", "   ", "   ", "   " },
            },
            latex = {
              enabled = true,
              converter = "latex2text",
              highlight = "RenderMarkdownMath",
              top_pad = 0,
              bottom_pad = 0,
            },
          },
        },
      }
    '';

    extraConfig = ''
      ------------------------------------------------------------------
      -- Options
      ------------------------------------------------------------------
      vim.g.mapleader = " "
      vim.opt.shell = "${pkgs.fish}/bin/fish"

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.conceallevel = 2

      ------------------------------------------------------------------
      -- Filetypes
      ------------------------------------------------------------------
      vim.filetype.add({
        pattern = { [".*%.blade%.php"] = "blade" },
        extension = { ejs = "html" },
      })

      ------------------------------------------------------------------
      -- Terminal: let image.nvim detect kitty
      ------------------------------------------------------------------
      if os.getenv("TERM") == "xterm-256color" then
        vim.env.TERM = "xterm-kitty"
      end

      ------------------------------------------------------------------
      -- NvimTree: line numbers
      ------------------------------------------------------------------
      pcall(function()
        local view = require("nvchad.configs.nvimtree").view
        if view then
          view.number = true
          view.relativenumber = true
        end
      end)

      ------------------------------------------------------------------
      -- Notifications: drop known noise
      ------------------------------------------------------------------
      do
        local notify = vim.notify
        local ignored = {
          "signatureHelp",
          "Couldn't find Astro in workspace",
        }

        vim.notify = function(msg, level, opts)
          if type(msg) == "string" then
            for _, pattern in ipairs(ignored) do
              if msg:find(pattern, 1, true) then return end
            end
          end
          notify(msg, level, opts)
        end
      end
    '';
  };
}
