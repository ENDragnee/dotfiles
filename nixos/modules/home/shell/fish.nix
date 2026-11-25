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

      if functions -q load_secrets
          load_secrets
      end

      colorscript -r
      zoxide init fish | source

      function zellij_tab_name_update --on-variable PWD
          if set -q ZELLIJ
              # 1. Determine directory name safely
              set -l dir_name
              if test "$PWD" = "$HOME"
                  set dir_name "~"
              else
                  set dir_name (path basename "$PWD")
              end

              # Fallback if path basename returns empty (e.g. root '/')
              if test -z "$dir_name"
                  set dir_name "/"
              end

              # 2. Extract active tab index from dump-layout without breaking in Nix
              set -l tab_num (command zellij action dump-layout 2>/dev/null | grep -E '^[[:space:]]*tab ' | grep -v 'tab_template' | grep -n 'focus=true' | cut -d: -f1)

              # 3. Construct target name
              set -l final_name
              if test -n "$tab_num"
                  set final_name "$tab_num. $dir_name"
              else
                  set final_name "$dir_name"
              end

              # 4. Apply title directly
              command zellij action rename-tab "$final_name" >/dev/null 2>&1
          end
      end

      # Hook into fish prompt so it runs whenever the prompt redraws
      function __zellij_rename_prompt_hook --on-event fish_prompt
          # Only run once on initial prompt render, then unhook itself
          functions -e __zellij_rename_prompt_hook
          zellij_tab_name_update
      end
    '';
  };
}
