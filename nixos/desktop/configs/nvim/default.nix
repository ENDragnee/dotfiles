{ pkgs, ... }:

{
  imports =[
    ./options.nix
    ./nvchad.nix
    ./treesitter.nix  # Uncomment as we generate them
    ./lsp.nix
    ./dap.nix
    ./plugins.nix
    ./mappings.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Replace Mason: Nix provides the binaries directly to Neovim's PATH
    extraPackages = with pkgs;[
      # PHP / Laravel
      php83Packages.composer
      nodePackages.intelephense
      php83Packages.php-codesniffer
      
      # Web Development
      nodePackages.vscode-langservers-extracted # HTML, CSS, JSON
      nodePackages.tailwindcss
      nodePackages.typescript-language-server
      nodePackages.prettier
      prettierd
      eslint_d
      
      # Python & C++ tools
      python311Packages.debugpy
      python311Packages.python-lsp-server
      black
      
      # Other Formatters/LSPs
      stylua
      shfmt
      bash-language-server
      docker-language-server
      # jdt-language-server # Uncomment if needed for java
    ];
  };
}
