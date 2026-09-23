{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # Core CLI & File Utils
      fastfetch
      yazi
      lsd
      ncdu
      btop
      ripgrep
      jq
      yq-go
      eza
      fzf
      zoxide
      tree
      file
      zoxide
      dwt1-shell-color-scripts
      kitty
      alacritty

      # Archives & Downloaders
      zip
      unzip
      p7zip
      yt-dlp
      spotdl
      aria2

      # Git & Terminal Multiplexing
      zellij
      gh

      # Networking & Diagnostics
      iperf3
      dnsutils
      nmap
      socat

      # Essential Dev Tools
      git
      gnumake
      gcc
      nodejs_24
      bun
      pnpm
      go
      python3
      rustup
      lua
      stylua
      antigravity-cli

      # Cross-Platform Apps / Browsers (if available/needed)
      #brave
      #discord
      #obs-studio
      #qbittorrent
      #vlc

      # Essential Fonts (Cross-platform compatible)
      nerd-fonts.hack
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
    ]
    ++ (
      with pkgs;
      lib.optionals stdenv.isLinux [
        # Keep Linux-only utilities strictly bounded here if you share configurations
        wl-clipboard
        libsecret
      ]
    );
}
