{ pkgs, lib, ... }:
{
  # Colors come from DMS dynamic theming (matugen): it writes
  # ~/.config/gtk-{3,4}.0/dank-colors.css on top of adw-gtk3 and the qt6ct
  # palette/icon theme in qt{5,6}ct.conf. Those files stay DMS-owned.

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "oomox-gruvbox-dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
      package = pkgs.nerd-fonts.fira-code;
    };
    # adw-gtk3 is GTK3-only; a GTK4 theme would also overwrite DMS's gtk-4.0/gtk.css.
    gtk4.theme = null;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct"; # installs qt5ct + qt6ct
  };

  # qtct sets "qt5ct"; DMS only accepts gtk3/qt6ct and Qt 6 apps need qt6ct to
  # read the DMS palette from qt6ct.conf.
  home.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
}
