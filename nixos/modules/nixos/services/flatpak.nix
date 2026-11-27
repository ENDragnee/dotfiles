{ ... }:
{
  services.flatpak = {
    enable = true;

    # Keep nixos-rebuild fast; update Flatpaks in the background or manually
    update.onActivation = false;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Set to true once you've verified everything you want is listed below
    uninstallUnmanaged = false;

    packages = [
      # --- Dev & Productivity ---
      "com.getpostman.Postman"
      "com.mongodb.Compass"
      "io.dbeaver.DBeaverCommunity"
      "md.obsidian.Obsidian"
      "org.gaphor.Gaphor"
      "org.libreoffice.LibreOffice"
      "org.kde.drawy"
      "re.sonny.Eloquent"

      # --- Communication & Privacy ---
      "com.slack.Slack"
      "com.protonvpn.www"
      "me.proton.Mail"
      "me.proton.Pass"

      # --- Gaming ---
      "com.usebottles.bottles"
      "net.lutris.Lutris"
      "net.davidotek.pupgui2" # ProtonUp-Qt
      "org.freedesktop.Platform.VulkanLayer.MangoHud"

      # --- Media & Reading ---
      "com.obsproject.Studio"
      "com.obsproject.Studio.Plugin.OBSVkCapture"
      "com.github.taiko2k.tauonmb" # Tauon
      "com.github.johnfactotum.Foliate"
      "org.kde.kdenlive"
      "org.mixxx.Mixxx"
      "org.nomacs.ImageLounge"

      # --- Utilities & Theming ---
      "com.github.tchx84.Flatseal"
      "org.freedownloadmanager.Manager"
      "org.gnome.clocks"
      "org.gtk.Gtk3theme.adw-gtk3-dark"
    ];
  };
}
