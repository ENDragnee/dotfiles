{ pkgs, ... }:

{
  programs.nixvim = {
    # 1. Provide nvim-tree using Nixvim's native module
    plugins.nvim-tree = {
      enable = true;
      filters.dotfiles = false;
      disableNetrw = true;
      hijackCursor = true;
      syncRootWithCwd = true;
      updateFocusedFile.enable = true;
      view = {
        width = 30;
        preserveWindowProportions = true;
      };
      renderer = {
        rootFolderLabel = false;
        highlightGit = true;
        indentMarkers.enable = true;
        icons = {
          show = {
            file = true;
            folder = true;
            folderArrow = true;
            git = true;
          };
        };
      };
    };

    plugins.web-devicons.enable = true;

    # 2. Fetch NvChad Core, Base46, UI, and Volt exactly from your lazy.lock
    extraPlugins =[
      (pkgs.vimUtils.buildVimPlugin {
        name = "NvChad";
        src = pkgs.fetchFromGitHub {
          owner = "NvChad";
          repo = "NvChad";
          rev = "d042cc975247c2aa55fcb228e5d146dc1dc6c648"; # From lazy.lock
          hash = ""; # Let Nix output the expected hash, then paste here
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "base46";
        src = pkgs.fetchFromGitHub {
          owner = "NvChad";
          repo = "base46";
          rev = "884b990dcdbe07520a0892da6ba3e8d202b46337"; # From lazy.lock
          hash = ""; # Let Nix output the expected hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "ui";
        src = pkgs.fetchFromGitHub {
          owner = "NvChad";
          repo = "ui";
          rev = "cb75908a86720172594b30de147272c1b3a7f452"; # From lazy.lock
          hash = ""; # Let Nix output the expected hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "volt";
        src = pkgs.fetchFromGitHub {
          owner = "NvChad";
          repo = "volt";
          rev = "620de1321f275ec9d80028c68d1b88b409c0c8b1"; # From lazy.lock
          hash = ""; # Let Nix output the expected hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "minty";
        src = pkgs.fetchFromGitHub {
          owner = "NvChad";
          repo = "minty";
          rev = "aafc9e8e0afe6bf57580858a2849578d8d8db9e0"; # From lazy.lock
          hash = ""; # Let Nix output the expected hash
        };
      })
    ];

    # 3. Simulate your chadrc.lua and bootstrap the themes
    extraConfigLuaPre = ''
      -- Replicate your chadrc.lua
      package.loaded["chadrc"] = {
          base46 = {
              theme = "gruvbox",
          }
      }
    '';

    extraConfigLua = ''
      local base46_cache = vim.fn.stdpath("data") .. "/base46/"
      
      -- Compile base46 if it hasn't been compiled yet
      if not vim.loop.fs_stat(base46_cache) then
          require("base46").compile()
      end
      
      -- Load the theme defaults and statusline
      dofile(base46_cache .. "defaults")
      dofile(base46_cache .. "statusline")
      
      -- Load NvChad Autocmds (which handles resizing, terminal behaviors, etc)
      require("nvchad.autocmds")
      
      -- Setup UI elements (Statusline, Tabufline)
      require("nvconfig").ui = {
          statusline = { theme = "default" },
          tabufline = { enabled = true },
      }
    '';
  };
}
