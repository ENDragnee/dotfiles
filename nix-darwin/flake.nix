{
  description = "nix-darwin configuration for mastwal-mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep other inputs as needed...
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix4nvchad,
      ...
    }@inputs:
    {
      # New macOS / nix-darwin configuration for your Mac mini M2
      darwinConfigurations."mastwal-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            # Replace an existing *.backup instead of failing activation.
            home-manager.overwriteBackup = true;
            
            home-manager.extraSpecialArgs = {
              inherit inputs nix4nvchad;
            };
            
            home-manager.users.mastwal = import ./darwin-home.nix;
          }
        ];
      };
    };
}
