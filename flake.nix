{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "electron-39.8.10" # For bitwarden-desktop
          ];
        };
    in
    {
      homeConfigurations =
        let
          mkHomeConfig =
            system:
            home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor system;
              modules = [ ./home ];
            };
        in
        {
          "gabriel" = mkHomeConfig "x86_64-linux";
          "gabriel@aarch64-linux" = mkHomeConfig "aarch64-linux";
        };

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with (pkgsFor system); [
            black
            cargo
            git-crypt
            nixfmt
            pre-commit
          ];
        };
      });
    };
}
