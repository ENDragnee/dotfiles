{ ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "lsd --color=auto --sort 'extension' --icon-theme unicode";
      la = "lsd -a --sort 'extension' --icon-theme unicode";
      ll = "lsd -lah --sort 'extension' --icon-theme unicode";
      l = "lsd --sort 'extension' --icon-theme unicode";
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
