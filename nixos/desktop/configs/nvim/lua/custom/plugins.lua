-- Plugin specs appended to the NvChad starter's lua/plugins (via plugins/init-2.lua).
return {
  { "mg979/vim-visual-multi", event = "VeryLazy" },

  ------------------------------------------------------------------
  -- LSP / Treesitter (override the NvChad + starter specs)
  ------------------------------------------------------------------
  {
    -- Not `config`: lazy also imports plugins/init-1.lua (the starter) on its own,
    -- after this file, so the starter's config would win. Hook in once it has loaded.
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(args)
          if args.data == "nvim-lspconfig" then
            require("custom.lsp")
            return true
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- nvim-treesitter `main` branch: setup() only takes install_dir, highlighting is
    -- started by NvChad's FileType autocmd, parsers are installed explicitly.
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
        "bash", "nix",
        "html", "css", "javascript", "typescript", "tsx", "vue", "astro",
        "json", "yaml", "prisma", "sql", "dockerfile",
        "c", "cpp", "rust",
        "php", "php_only", "blade",
        "go", "gomod", "python",
        "markdown", "markdown_inline",
      })
    end,
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      ts.setup()
      ts.install(opts.ensure_installed)
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
      require("custom.dap")
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
      require("telescope").load_extension("project")
    end,
  },

  ------------------------------------------------------------------
  -- AI: Copilot (inline autocomplete only) + Claude Code
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

  ------------------------------------------------------------------
  -- Laravel & Web helpers
  ------------------------------------------------------------------
  { "adalessa/laravel.nvim", ft = { "php", "blade" } },
  { "mattn/emmet-vim", ft = { "html", "css", "blade", "ejs", "javascriptreact", "typescriptreact" } },

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
