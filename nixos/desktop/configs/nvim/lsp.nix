{ pkgs, ... }:

{
  programs.nixvim = {
    # Ensure standalone formatters and linters are available in Neovim's PATH
    extraPackages = with pkgs;[
      php83Packages.pint
      nodePackages.blade-formatter
      prettierd
      eslint_d
      stylua
      black
      # Note: laravel-ls is highly specific and might need to be built via 
      # composer globally or managed outside if not present in nixpkgs.
    ];

    plugins = {
      # 1. Conform Formatting Setup
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 500;
          };
          
          # Map formatters based on your Mason ensure_installed list
          formatters_by_ft = {
            php = [ "pint" ];
            blade = [ "blade-formatter" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            vue = [ "prettierd" "prettier" ];
            css = [ "prettierd" "prettier" ];
            html = [ "prettierd" "prettier" ];
            json = [ "prettierd" "prettier" ];
            lua = [ "stylua" ];
            python = [ "black" ];
            bash = [ "shfmt" ];
          };
        };
      };

      # 2. LSP Servers
      lsp = {
        enable = true;
        
        # This replaces mason-lspconfig
        servers = {
          # PHP
          intelephense.enable = true;
          
          # Web Development
          html.enable = true;
          cssls.enable = true;
          tailwindcss.enable = true;
          ts_ls.enable = true; # Replaces "typescript-language-server" (Nixvim standard name)
          volar.enable = true; # Vue language server
          eslint.enable = true;

          # Other tools
          bashls.enable = true;
          pylsp.enable = true;
          graphql.enable = true;
          prismals.enable = true; # Prisma
          jinja_lsp.enable = true;
          dockerls.enable = true;
          dotls.enable = true;
          jdtls.enable = true; # Java
        };
      };
    };

    # 3. Custom Laravel-LS initialization (Fallback if not natively supported by Nixvim)
    # Since laravel-ls is a specialized composer package, we register it manually 
    # to behave exactly as it did in your init.lua.
    extraConfigLua = ''
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      -- Register Laravel-LS manually if it's available in your PATH
      if not configs.laravel_ls then
        configs.laravel_ls = {
          default_config = {
            cmd = { "laravel-ls" },
            filetypes = { "blade", "php" },
            root_dir = function(fname)
              return lspconfig.util.root_pattern("composer.json", ".git")(fname)
            end,
            settings = {},
          },
        }
      end

      -- Only start it if the executable is found
      if vim.fn.executable("laravel-ls") == 1 then
        lspconfig.laravel_ls.setup({})
      end
    '';
  };
}
