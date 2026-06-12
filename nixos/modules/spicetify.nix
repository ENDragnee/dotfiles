{ pkgs, inputs, ... }:
{

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
}
