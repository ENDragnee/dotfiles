{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
    inputs.nix4nvchad.homeManagerModule
    inputs.spicetify-nix.homeManagerModules.default
    ./desktop/configs/nvim/nvchad.nix
    ./modules/packages.nix
  ];
  home.username = "end";
  home.homeDirectory = "/home/end";
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  fonts.fontconfig.enable = true;

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
        keyboardShortcut
        history
      ];
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
      ];
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];

      theme = {
        name = "Gruvbox";
        src = pkgs.writeTextDir "color.ini" ''
          [Retro-Dark]
          text               = FBF1C7
          subtext            = BDAE93
          main               = 282828
          sidebar            = 1D2021
          player             = 1D2021
          card               = 32302F
          shadow             = 1D2021
          selected-row       = 504945
          button             = FE8019
          button-active      = FABD2F
          button-disabled    = 7C6F64
          tab-active         = FE8019
          notification       = 32302F
          notification-error = FB4934
          misc               = 928374
        '';

        # Optional adjustments depending on your setup
        injectCss = true;
        replaceColors = true;
      };
      colorScheme = "Retro-Dark";
    };

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
  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    disabledTrayIcon=false
    showStartupLaunchMessage=false
    useGrimAdapter=true
  '';

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    iconTheme = {
      name = "oomox-gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
    font = {
      name = "FiraCode Nerd Font 12";
      package = pkgs.nerd-fonts.fira-mono;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.zellij}/bin/zellij";
        args = [
          "attach"
          "-c"
        ];
      };

      env.TERM = "xterm-256color";
      font = {
        size = 14;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
  programs.niri.settings.binds = lib.mkForce { };
  programs.dank-material-shell = {
    enable = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    clipboardSettings = {
      maxHistory = 1000;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = false;
      disabled = false;
      disableHistory = false;
      disablePersist = true;
    };
    niri = {
      enableKeybinds = false;
      includes = {
        enable = true;
        override = true;
        # originalFileName = "base";
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
  xdg.configFile."niri/custom.kdl".source = ./desktop/configs/niri/my-config.kdl;

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim wrapper";
      genericName = "Text Editor";
      exec = "ghostty -e nvim %F";
      terminal = false;
      icon = "nvim";
      categories = [
        "Utility"
        "TextEditor"
      ];
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };
  };

  home.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    TERM = "xterm-256color";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
  xresources.properties = {
    "XTerm*faceName" = "Hack Nerd Font:size=12";
    "XTerm*renderFont" = "true";
    "XTerm*shading" = "100";
    "XTerm*scrollBar" = "false";
    "XTerm*vt100*geometry" = "100x30";
    "XTerm*saveLines" = "4096";
    "XTerm*charClass" = "33:48,35:48,37:48,43:48,45-47:48,58:48,61:48,63:48,64:48,95:48,126:48";

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
