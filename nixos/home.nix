{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
  ];
  home.username = "end";
  home.homeDirectory = "/home/end";
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  home.packages = with pkgs; [
    fastfetch
    yazi
    lsd
    # home-manager
    ani-cli
    xterm
    picard
    linux-wifi-hotspot

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
    # prettier
    # prettierd

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
  fonts.fontconfig.enable = true;

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "ENDragnee";
        email = "mesfinmastwal@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    # theme = {
    #   name = "Gruvbox-Dark";
    #   package = pkgs.gruvbox-dark-gtk;
    # };
    iconTheme = {
      name = "oomox-gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
    font = {
      name = "FiraCode Nerd Font 12"; # Family name and size
      package = pkgs.nerd-fonts.fira-mono; # Package containing the font
    };
    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};
    gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      terminal.shell = {
        program = "${pkgs.zellij}/bin/zellij";
        args = ["attach" "-c"];
      };

      env.TERM = "xterm-256color";
      font = {
        size = 14;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
  programs.dank-material-shell = {
    enable = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
    };
    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true; # Pasting items from the clipboard (wtype)

    #    settings = {
    #      theme = "dark";
    #      dynamicTheming = true;
    #    };
    #
    #    session = {
    #      isLightMode = false;
    #    };
    #
    clipboardSettings = {
      maxHistory = 25;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = true;
      disabled = false;
      disableHistory = false;
      disablePersist = true;
    };
    niri = {
      enableKeybinds = true; # Set to true to use DMS binds alongside yours:
      includes = {
        enable = true; # LEAVE THIS ENABLED
        override = true; # LEAVE THIS TRUE (So DMS settings override your base config)
        originalFileName = "base"; # DMS will use this name for your base config
        filesToInclude = [
          "../custom"
          "alttab"
          "animations"
          "binds"
          "colors"
          "cursor"
          "layout"
          "outputs"
          "windowrules"
          "wpblur"
        ];
      };
    };
  };
  xdg.configFile."niri/custom.kdl".source = ./niri-config.kdl;
  # programs.home-manager.enable = true;
  home.sessionVariables = {
    # QT_STYLE_OVERRIDE = "kvantum";
    # QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_QPA_PLATFORMTHEME = "kvantum";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    TERM = "xterm-256color";
  };
  xresources.properties = {
    "XTerm*faceName" = "Hack Nerd Font:size=12";
    "XTerm*renderFont" = "true";
    "XTerm*shading" = "100";
    "XTerm*scrollBar" = "false";
    "XTerm*vt100*geometry" = "100x30";
    "XTerm*saveLines" = "4096";
    "XTerm*charClass" = "33:48,35:48,37:48,43:48,45-47:48,58:48,61:48,63:48,64:48,95:48,126:48";

    # Gruvbox Dark Colors
    "XTerm*background" = "#282828";
    "XTerm*foreground" = "#ebdbb2";
    "XTerm*cursorColor" = "#ebdbb2";
    "XTerm*color0" = "#282828";
    "XTerm*color8" = "#928374";
    "XTerm*color1" = "#cc241d";
    "XTerm*color9" = "#fb4934";
    "XTerm*color2" = "#98971a";
    "XTerm*color10" = "#b8bb26";
    "XTerm*color3" = "#d79921";
    "XTerm*color11" = "#fabd2f";
    "XTerm*color4" = "#458588";
    "XTerm*color12" = "#83a598";
    "XTerm*color5" = "#b16286";
    "XTerm*color13" = "#d3869b";
    "XTerm*color6" = "#689d6a";
    "XTerm*color14" = "#8ec07c";
    "XTerm*color7" = "#a89984";
    "XTerm*color15" = "#ebdbb2";
  };
  # programs.fish = {
  #   enable = true;
  #   interactiveShellInit = ''
  #     set fish_greeting # Disable greeting
  #     zoxide init fish | source
  #     set -gx SOPS_AGE_KEY_FILE "$HOME/.age/key.txt"
  #   '';
  #   # shellAliases = {
  #   #   ll = "lsd -l";
  #   #   ls='lsd --color=auto --sort "extension"';
  #   #   la='lsd -a --sort "extension"';
  #   #   ll='lsd -lah --sort "extension"';
  #   #   l='lsd --sort "extension"';
  #   #   clear='clear && colorscript -r';
  #   #   y="yazi";
  #   #   ne="fastfetch";
  #   #   cd="z";
  #   #   ne="fastfetch";
  #   # };
  #   # plugins = [
  #   #   {
  #   #     name = "grc";
  #   #     src = pkgs.fishPlugins.grc.src;
  #   #   }
  #   # ];
  # };
  home.stateVersion = "25.11";
}
