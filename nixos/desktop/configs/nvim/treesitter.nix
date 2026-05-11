{ pkgs, ... }:

{
  programs.nixvim = {
    # Provide compilers and tools needed to compile the custom Blade parser at runtime
    extraPackages = with pkgs;[
      gcc
      git
      tree-sitter
    ];

    plugins.treesitter = {
      enable = true;
      
      # Let Nix manage the standard parsers (replacing your auto-install lua loop)
      nixGrammars = true; 
      
      settings = {
        highlight = {
          enable = true;
          # We don't disable additional_vim_regex_highlighting globally here 
          # because your autocmd handles it per-buffer for blade.
        };
        indent = {
          enable = true;
        };
        ensure_installed =[
          "vim"
          "lua"
          "vimdoc"
          "html"
          "css"
          "javascript"
          "php"
          "java"
          "graphql"
          "typescript"
          "python"
        ];
      };
    };

    # 1. Setup Custom Blade Parser & Registration
    extraConfigLua = ''
      -- Define the custom parser
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.blade = {
          install_info = {
              url = "https://github.com/EmranMR/tree-sitter-blade",
              files = { "src/parser.c", "src/scanner.cc" },
              branch = "main",
          },
          filetype = "blade",
      }

      vim.treesitter.language.register("blade", "blade")
      
      -- Auto-install blade if it's missing (since it's not managed by Nix)
      local function is_blade_installed()
          return #vim.api.nvim_get_runtime_file("parser/blade.*", false) > 0
      end

      if not is_blade_installed() then
          vim.schedule(function()
              vim.cmd("TSInstallSync blade")
          end)
      end
    '';

    # 2. Start Highlighting and Indentation natively (Matching your custom autocommand)
    autoCmd = [
      {
        event =[ "FileType" ];
        # We use __raw to map your exact Lua function
        callback = {
          __raw = ''
            function(args)
                -- Safely start treesitter
                local ok = pcall(vim.treesitter.start, args.buf)

                if ok then
                    -- Enable treesitter indentation
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    -- Fallback to regex highlighting for blade (replaces additional_vim_regex_highlighting)
                    if vim.bo[args.buf].filetype == "blade" then
                        vim.bo[args.buf].syntax = "on"
                    end
                end
            end
          '';
        };
      }
    ];
  };
}
