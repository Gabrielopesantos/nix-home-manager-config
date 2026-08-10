{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr.url = "github:herdrdev/herdr";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      herdr,
      nix-index-database,
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
          overlays = [
            herdr.overlays.default
          ];
        };
    in
    {
      homeConfigurations =
        let
          mkHomeConfig =
            { host, system }:
            home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor system;
              modules = [
                nix-index-database.homeModules.nix-index
                ./home
                ./hosts/${host}.nix
              ];
            };
        in
        {
          "gabriel" = mkHomeConfig {
            host = "casper";
            system = "x86_64-linux";
          };
          "gsantos@lenovo" = mkHomeConfig {
            host = "lenovo";
            system = "x86_64-linux";
          };
        };

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          packages = with (pkgsFor system); [
            git-crypt
            npins
          ];
        };
      });
    };
}
