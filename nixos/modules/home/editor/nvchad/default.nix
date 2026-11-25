# NvChad via nix4nvchad, shared by NixOS (home/end.nix) and nix-darwin.
# The Lua lives in the repo's nvim/lua/custom, which also works as a plain
# (Mason-based) NvChad config; this module only adds tools and store paths.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.nvchad;

  python = pkgs.python314.withPackages (ps: [
    ps.python-lsp-server
    ps.black
    ps.debugpy
  ]);

  # pkgs.typescript is TS 7 (Go-native, no tsserver.js); ts_ls and the Vue/Astro
  # plugins need the JS tsserver from TS 5.
  typescript = pkgs.typescript_5;

  # Store paths the Lua side needs, exposed as `require("custom.nix")`
  # (see nvim/lua/custom/paths.lua for the non-Nix fallbacks).
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

  repoNvim = ../../../../../nvim;

  nixLua = pkgs.writeText "nix.lua" "return ${lib.generators.toLua { } nixPaths}\n";

  # Needs a git-based flake (nixos-rebuild/darwin-rebuild --flake <repo>/...):
  # the path reaches outside the flake directory into the repo root.
  luaDir = pkgs.runCommandLocal "nvchad-custom-lua" { } ''
    mkdir -p $out/custom
    cp ${repoNvim + "/lua/custom"}/*.lua $out/custom/
    cp ${nixLua} $out/custom/nix.lua
  '';
in
{
  imports = [ inputs.nix4nvchad.homeManagerModules.default ];

  options.dotfiles.nvchad = {
    java.enable = lib.mkEnableOption "Java/Kotlin tooling (JDK, kotlin-language-server, ktfmt)";
    prose.enable = lib.mkEnableOption "ltex-ls-plus grammar checking";
    latex.enable = lib.mkEnableOption "LaTeX math rendering in markdown (TeX Live, latex2text)";
  };

  config.programs.nvchad = {
    enable = true;
    # ~/.config/nvim is regenerated on every switch; backups only pile up.
    backup = false;

    # Same theme and plugin versions as the standalone config in nvim/. After
    # :Lazy update, copy ~/.config/nvim/lazy-lock.json back to nvim/ to keep it.
    chadrcConfig = builtins.readFile (repoNvim + "/lua/chadrc.lua");
    lazy-lock = builtins.readFile (repoNvim + "/lazy-lock.json");

    extraPackages =
      with pkgs;
      [
        # --- Core Build & Utils ---
        gcc
        tree-sitter
        git
        pkg-config
        ripgrep
        fd
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
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [ wl-clipboard ]
      ++ lib.optionals cfg.java.enable [
        jdk
        kotlin-language-server
        ktfmt
      ]
      ++ lib.optionals cfg.prose.enable [ ltex-ls-plus ]
      ++ lib.optionals cfg.latex.enable [
        python3Packages.pylatexenc # latex2text
        texliveMedium
        poppler-utils
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
