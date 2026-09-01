{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      texlivePackages.librebaskerville
      texlivePackages.librebodoni
      cinzel
      rPackages.ggplayfair
    ];
  };
}
