{ pkgs, ... }:

{
  programs.nixvim = {
    # 1. Native Nixvim Plugins
    plugins = {
      telescope.enable = true;
      
      copilot-lua = {
        enable = true;
        settings = {
          panel.enabled = true;
          suggestion = {
            enabled = true;
            auto_trigger = true;
            keymap = {
              accept = "<C-]>";
              next = "<M-]>";
              prev = "<M-[>";
              dismiss = "<C-}>";
            };
          };
          filetypes = {
            yaml = false;
            markdown = false;
            help = false;
            agentic = false;
            "agentic-prompt" = false;
          };
        };
      };

      # Basic CopilotChat setup (commands and overrides are done in extraConfigLua)
      copilot-chat.enable = true;
    };

    # Emmet Global Settings
    globals.user_emmet_settings = {
      blade = { extends = "html"; };
    };

    # 2. Fetch Non-Native Plugins (Matching your lazy.lock)
    extraPlugins = with pkgs.vimPlugins;[
      vim-visual-multi
      emmet-vim
      telescope-project-nvim
      img-clip-nvim
      nui-nvim
      plenary-nvim
      nvim-nio

      (pkgs.vimUtils.buildVimPlugin {
        name = "laravel.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "adalessa";
          repo = "laravel.nvim";
          rev = "e63451559abeec2bf977e832fcd4dd85925f9e66"; # From lazy.lock
          hash = ""; # Let Nix calculate the hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "projectmgr.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "charludo";
          repo = "projectmgr.nvim";
          rev = "c48b359cbbf3e3783ae86b5dde0929313a4f5064"; # From lazy.lock
          hash = ""; # Let Nix calculate the hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "agentic.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "carlos-algms";
          repo = "agentic.nvim";
          rev = "f36092681e438af4b4862fc0543c78b2a41586db"; # From lazy.lock
          hash = ""; # Let Nix calculate the hash
        };
      })
    ];

    # 3. Setup Logic for Custom Plugins
    extraConfigLua = ''
      -- --- Telescope Extensions ---
      require("telescope").load_extension("project")
      
      -- --- Laravel.nvim Setup ---
      -- Check if composer is initialized, to prevent errors on non-php projects
      pcall(function()
          require("laravel").setup()
      end)

      -- --- CopilotChat Setup (Visual Selection overrides and Commands) ---
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      chat.setup({
          debug = false,
          show_help = true,
          window = {
              layout = "float",
              relative = "cursor",
              width = 0.8,
              height = 0.6,
          },
          auto_follow_cursor = false,
          selection = function(source)
              source = source or {}
              source.buf = source.buf or vim.api.nvim_get_current_buf()
              local visual = select.visual(source)
              if visual and #visual > 0 then
                  return visual
              end
              return select.buffer(source)
          end
      })

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


      -- --- Agentic.nvim & Goose Setup ---
      require("agentic").setup({
          provider = "gemini-acp",
          acp_providers = {["gemini-acp"] = {
                  command = "gemini",
                  args = { "--experimental-acp", "--model", "gemini-3-flash-preview" },
                  env = { GEMINI_API_KEY = os.getenv("NEOVIM_GEMINI_API_KEY") },
              },["claude-agent-acp"] = {
                  env = { ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY") },
              },
              ["codex-acp"] = {
                  command = "~/.local/bin/codex-acp",
              },["goose-ollama"] = {
                  command = "/home/end/.local/bin/goose",
                  args = { "acp", "--with-builtin", "developer" },
                  env = {
                      OLLAMA_HOST = "http://localhost:11434",
                      GOOSE_TELEMETRY = "false",
                      GOOSE_PROVIDER = "ollama",
                      GOOSE_MODEL = "llama3.2:latest",
                      HOME = "/home/end",
                      USER = "end",
                      GOOSE_WORKING_DIR = vim.fn.getcwd(),
                      GOOSE_SESSION_ID = "nvim-session",
                      OLLAMA_KEEP_ALIVE = "-1",
                  },
              },
              ["my-cool-acp"] = {
                  name = "My Cool ACP",
                  command = "cool-acp",
                  args = { "--mode", "acp" },
                  env = { COOL_API_KEY = os.getenv("COOL_API_KEY") },
              },
          },
      })
    '';
  };
}
