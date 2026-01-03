source $__fish_config_dir/enviroment.fish

if not functions -q zellij_auto
    source $__fish_config_dir/functions/zellij_auto.fish
end

set -gx PNPM_HOME "/home/end/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    alias ls='lsd --color=auto --sort "extension"'
    alias la='lsd -a --sort "extension"'   
    alias ll='lsd -lah --sort "extension"'
    alias l='lsd --sort "extension"' 
    alias l.='lsd -A | egrep '^\.' --sort "extension"'
    alias clear='clear && colorscript -r'
    alias y="yazi"
    alias ne="fastfetch"
    colorscript -r
    alias clear="clear && colorscript -r"
    alias proton-d="protonup -o ~/Downloads --download -t"
    alias proton-l="protonup -o ~/Downloads --download --releases"
    alias ani="ani-cli -q 720 -f"
    alias ani-l="ani-cli -q 480 -f"
    alias ani-d="ani-cli -q 720 -d -f -p ~/real/Anime/Downloads/"
    alias intel-mem='lspci  -v -s  $(lspci | grep VGA | cut -d" " -f 1) | grep " prefetchable"'
    alias pak="flatpak --user"
    alias pak="flatpak --user"
    alias cd="z"
    zoxide init fish | source
end


# Created by `pipx` on 2025-10-19 14:49:23
set PATH $PATH /home/end/.local/bin
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
pyenv init - | source

set -gx SOPS_AGE_KEY_FILE "$HOME/.age/key.txt"

# Flutter path
# fish_add_path -g -p ~/develop/flutter/bin
# fish_add_path -g -p ~/develop/android-studio/bin

fish_add_path -g -p ~/.config/emacs/bin

# pnpm
set -gx PNPM_HOME "/home/end/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
