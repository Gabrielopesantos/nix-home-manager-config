{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr.url = "github:herdrdev/herdr";
    grok-bot.url = "github:jordangarrison/grok-bot-flake";
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
      grok-bot,
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
            grok-bot.overlays.default
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
          "gabriel-headless" = self.homeConfigurations.gabriel.extendModules {
            modules = [ { gui.enable = lib.mkForce false; } ];
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
