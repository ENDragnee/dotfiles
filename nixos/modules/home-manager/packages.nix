{
  pkgs,
  zen-browser,
  ...
}:
{
  home.packages = with pkgs; [
    # --- Browsers ---
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    brave

    # --- Terminals & Shell ---
    kitty
    ghostty
    zellij
    fastfetch
    yazi
    lsd
    zoxide
    fzf
    ripgrep
    jq
    yq-go
    glow
    dwt1-shell-color-scripts

    # --- Wayland & Desktop Utilities ---
    wl-clipboard
    xwayland-satellite
    xdg-utils
    polkit_gnome
    fuzzel
    wdisplays
    pwvucontrol
    qpwgraph
    grim
    slurp
    flameshot
    hyprpicker

    # --- GUI Apps ---
    nemo-with-extensions
    papers
    qalculate-gtk
    telegram-desktop
    discord
    vlc
    qbittorrent
    syncthing
    veracrypt
    gparted
    gnome-disk-utility
    xarchiver
    bulky

    # --- Media, Fun & CLI Apps ---
    ffmpeg
    yt-dlp
    ani-cli
    spotdl
    chess-tui
    stockfish

    # --- Development & AI ---
    gh
    sops
    gcc
    gnumake
    nodejs_24
    bun
    pnpm
    go
    rustup
    lua
    tree-sitter
    stylua
    distrobox
    antigravity-cli
    opencode
    claude-code

    # --- Archives & Core CLI Utils ---
    zip
    unzip
    xz
    p7zip
    zstd
    file
    which
    tree
    gnused
    gnutar
    gawk
    gnupg
    openssl
    android-tools

    # --- Networking & Remote Access ---
    mtr
    iperf3
    dnsutils
    aria2
    socat
    nmap
    ipcalc
    linux-wifi-hotspot
    wlvncc

    # --- System Monitoring & Diagnostics ---
    btop
    btdu
    iotop
    iftop
    nethogs
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

    # --- Fonts ---
    nerd-fonts.hack
    nerd-fonts.fira-mono
    liberation_ttf

    # --- Theming (GTK & Qt6) ---
    adw-gtk3
    gruvbox-dark-gtk
    gruvbox-dark-icons-gtk
    gruvbox-kvantum
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
