{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "lsd --color=auto --sort 'extension'";
      la = "lsd -a --sort 'extension'";
      ll = "lsd -lah --sort 'extension'";
      l = "lsd --sort 'extension'";
      clear = "clear && colorscript -r";
      y = "yazi";
      ne = "fastfetch";
      cd = "z";
    };
    interactiveShellInit = ''
      if test -f ~/.config/fish/functions/load-secrets.fish
        source ~/.config/fish/functions/load-secrets.fish
      end
      load_secrets
      colorscript -r
      zoxide init fish | source
    '';
  };
}
