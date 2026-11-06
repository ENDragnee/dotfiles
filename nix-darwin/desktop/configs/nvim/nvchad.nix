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
        python3Packages.pylatexenc
        texliveMedium # provides pdflatex, dvisvgm, etc.
        poppler-utils # provides pdftoppm for fast PDF-to-PNG conversions

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
            -- Enables rendering standalone $$ math blocks as inline images
            processor = "magick_cli",
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
      vim.opt.conceallevel = 2

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
      pcall(function()
        local nvim_tree_config = require("nvchad.configs.nvimtree")
        if nvim_tree_config and nvim_tree_config.view then
          nvim_tree_config.view.number = true
          nvim_tree_config.view.relativenumber = true
        end
      end)

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
              language = "en-US",
            },
          },
          on_attach = function(client, bufnr)
            require("ltex_extra").setup({
              load_langs = { "en-US" },
            })
            if lsp.on_attach then
              lsp.on_attach(client, bufnr)
            end
          end,
        })
      end)
    '';
  };
}
