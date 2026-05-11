{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      # Tell NvChad where to cache the compiled themes
      base46_cache = "v:lua.vim.fn.stdpath('data') .. '/base46/'";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      tabstop = 4;
      expandtab = true;
      smartindent = true;
      # backupcopy = "yes"; # Kept commented out as per your init.lua
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    
    # Your custom clipboard implementation mapping
    extraConfigLuaPre = ''
      vim.g.clipboard = {
          name = "wl-clipboard-x11",
          copy = {
              ["+"] = "wl-copy",
              ["*"] = "wl-copy",
          },
          paste = {
              ["+"] = "wl-paste",
              ["*"] = "wl-paste",
          },
          cache_enabled = 1,
      }
    '';
  };
}
