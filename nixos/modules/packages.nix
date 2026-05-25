{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    yazi
    lsd
    ncdu
    btdu
    gnuchess
    ani-cli
    xterm
    picard
    linux-wifi-hotspot
    qalculate-gtk
    eloquent
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    sops
    openssl
    wl-clipboard

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # productivity
    glow # markdown previewer in terminal
    zellij
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    htop
    nethogs
    stockfish
    syncthing

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files
    xwayland-satellite
    bibata-cursors

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    #my apps
    vlc
    veracrypt
    spicetify-cli
    alacritty
    gparted
    nemo-with-extensions
    fuzzel
    rofi
    xdg-desktop-portal-gnome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    telegram-desktop
    pwvucontrol
    qpwgraph
    lxappearance
    spotify
    dwt1-shell-color-scripts
    ghostty
    xdg-utils
    kdePackages.kdeconnect-kde
    papers
    evince
    xarchiver
    drawio
    wine-staging
    chess-tui
    brave
    obs-studio
    flameshot
    hyprpicker
    gnome-disk-utility
    qbittorrent
    polkit_gnome
    grim
    slurp

    #dev tools
    nodejs_24
    bun
    pnpm
    gcc
    go
    python315
    php
    php84Packages.composer
    gnumake
    rustup
    tree-sitter
    lua
    zoxide
    distrobox
    ollama
    pyenv
    stylua
    gemini-cli

    #fonts
    nerd-fonts.hack
    nerd-fonts.hurmit
    nerd-fonts.iosevka
    nerd-fonts.fira-mono
    nerd-fonts.mononoki
    nerd-fonts.roboto-mono
    nerd-fonts.daddy-time-mono
    nerd-fonts.fantasque-sans-mono
    corefonts
    liberation_ttf

    #theme
    gruvbox-kvantum
    gruvbox-dark-gtk
    gruvbox-gtk-theme
    gruvbox-dark-icons-gtk
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    adw-gtk3
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
