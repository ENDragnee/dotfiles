{ pkgs, lib, ... }:
let
  python = pkgs.python314.withPackages (ps: [
    ps.python-lsp-server
    ps.black
    ps.debugpy
  ]);

  # pkgs.typescript is TS 7 (Go-native, no tsserver.js); ts_ls and the Vue/Astro
  # plugins need the JS tsserver from TS 5.
  typescript = pkgs.typescript_5;

  # Store paths the Lua side needs, exposed as `require("custom.nix")`.
  nixPaths = {
    typescript_node_modules = "${typescript}/lib/node_modules";
    tsdk = "${typescript}/lib/node_modules/typescript/lib";
    tsserver = "${typescript}/lib/node_modules/typescript/lib/tsserver.js";
    vue_typescript_plugin = "${pkgs.vue-language-server}/lib/language-tools/packages/typescript-plugin";
    js_debug = "${pkgs.vscode-js-debug}/bin/js-debug";
    lldb_dap = "${pkgs.lldb}/bin/lldb-dap";
    python = "${python}/bin/python";
    clangd_query_driver = lib.concatStringsSep "," [
      "${pkgs.stdenv.cc}/bin/cc"
      "${pkgs.stdenv.cc}/bin/gcc"
      "${pkgs.clang}/bin/clang"
      "${pkgs.clang}/bin/clang++"
    ];
  };

  luaDir = pkgs.symlinkJoin {
    name = "nvchad-custom-lua";
    paths = [
      ./lua
      (pkgs.writeTextDir "custom/nix.lua" "return ${lib.generators.toLua { } nixPaths}\n")
    ];
  };
in
{
  programs.nvchad = {
    enable = true;
    # ~/.config/nvim is regenerated on every switch; backups only pile up.
    backup = false;

    extraPackages = with pkgs; [
      # --- Core Build & Utils ---
      gcc
      tree-sitter
      git
      pkg-config
      ripgrep
      fd
      wl-clipboard
      imagemagick # image.nvim (magick_cli processor)

      # --- Lua / Shell / Nix ---
      stylua
      bash-language-server
      nil

      # --- Web / TS (Next.js, Astro, Vue, Solid, NestJS) ---
      typescript-language-server
      vscode-langservers-extracted # html, css, json, eslint
      tailwindcss-language-server
      vue-language-server
      astro-language-server
      prisma-language-server
      oxlint
      oxfmt
      prettierd # fallback for astro, markdown, etc.

      # --- C, C++, Rust ---
      rust-analyzer
      clang
      clang-tools # clangd + clang-format

      # --- Laravel / PHP ---
      php85
      php85Packages.composer
      intelephense
      blade-formatter

      # --- Docs & Markdown ---
      harper
      markdown-oxide

      # --- Go & Python ---
      go
      gopls
      python
    ];

    # Loaded by lazy.nvim before extraConfig, so the module path is set here.
    extraPlugins = ''
      package.path = "${luaDir}/?.lua;${luaDir}/?/init.lua;" .. package.path
      return require("custom.plugins")
    '';

    extraConfig = ''
      require("custom")
    '';
  };
}
