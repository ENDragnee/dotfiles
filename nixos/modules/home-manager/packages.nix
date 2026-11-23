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
    # chromium # redundant with brave
    # qutebrowser # pulls in heavy QtWebEngine

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
    alacritty # redundant with kitty/ghostty (remove alacritty.nix import if unused)
    # xterm # legacy X11 terminal
    # eza # redundant with lsd
    # superfile # redundant with yazi

    # --- Wayland & Desktop Utilities ---
    wl-clipboard
    xwayland-satellite
    xdg-desktop-portal-gnome
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
    # rofi # redundant with fuzzel
    # lxappearance # GTK2/X11 tool; usually unnecessary on Wayland
    # bibata-cursors # already in system-wide environment.systemPackages
    # kdePackages.kdeconnect-kde # already installed by programs.kdeconnect.enable

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
    # evince # redundant with papers (modern replacement)
    # drawio # heavy Electron app; uncomment if used regularly
    # obs-studio # heavy closure; uncomment when recording/streaming
    # handbrake # heavy; ffmpeg already handles transcoding
    # wine-staging # pulls massive 32-bit/64-bit graphics stack
    # picard # music tagger; uncomment when needed
    # ventoy-full-gtk # only needed when flashing USBs

    # --- Media, Fun & CLI Apps ---
    ffmpeg
    yt-dlp
    ani-cli
    spotdl
    chess-tui
    stockfish
    # gnuchess # redundant with stockfish
    # cowsay

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
    ollama-vulkan
    # ollama # duplicate (was listed twice; replaced by ollama-vulkan)
    # python315 # conflicts with python314 in nvchad.nix; move to project flakes
    # pyenv # prefer nix-direnv / per-project flakes
    # php # conflicts with php85 in nvchad.nix; move to project flakes
    # php84Packages.composer # move to project flakes

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
    plocate
    android-tools
    # minidlna # media server; uncomment if actively streaming over LAN

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
    # ldns # redundant with dnsutils (dig)
    # tigervnc # redundant if using wlvncc/virt-viewer

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
    # htop # redundant with btop
    # ncdu # redundant with btdu

    # --- Fonts ---
    # Keep only the 1-2 Nerd Fonts you actually use; iosevka is especially large
    nerd-fonts.hack
    nerd-fonts.fira-mono
    liberation_ttf
    # nerd-fonts.iosevka
    # nerd-fonts.hurmit
    # nerd-fonts.mononoki
    # nerd-fonts.roboto-mono
    # nerd-fonts.daddy-time-mono
    # nerd-fonts.fantasque-sans-mono
    # corefonts # unfree MS fonts; uncomment only if needed for Wine/LibreOffice

    # --- Theming (GTK & Qt6) ---
    adw-gtk3
    gruvbox-dark-gtk
    gruvbox-dark-icons-gtk
    gruvbox-kvantum
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    # gruvbox-gtk-theme # redundant with gruvbox-dark-gtk
    # libsForQt5.qt5ct # drop Qt5 stack unless you have legacy Qt5 apps
    # libsForQt5.qtstyleplugin-kvantum
  ];
}
