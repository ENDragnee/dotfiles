#Folders
set -qU XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -qU XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -qU XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache

#Default Apps
set -gx EDITOR nvim
set -gx VISUAL gedit
