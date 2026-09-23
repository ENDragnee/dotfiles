{ ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "lsd --color=auto --sort 'extension'";
      la = "lsd -a --sort 'extension'";
      ll = "lsd -lah --sort 'extension'";
      l = "lsd --sort 'extension'";
      y = "yazi";
      ne = "fastfetch";
      clear = "clear && colorscript -r";
      cd = "z";
    };

    interactiveShellInit = "";
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
