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
            {
              host,
              system,
              headless ? false,
            }:
            home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor system;
              modules = [
                nix-index-database.homeModules.nix-index
                ./home
                ./hosts/${host}.nix
              ]
              # mkForce because the host files set gui.enable themselves.
              ++ lib.optional headless { gui.enable = lib.mkForce false; };
            };

          hosts = {
            "gabriel" = {
              host = "casper";
              system = "x86_64-linux";
            };
            "gsantos@lenovo" = {
              host = "lenovo";
              system = "x86_64-linux";
            };
          };
        in
        # Each host gets a "<name>-headless" companion output, which is what
        # `make headless` builds. There is no way to override a module option
        # from the home-manager command line, so it has to exist as an output.
        lib.concatMapAttrs (name: args: {
          ${name} = mkHomeConfig args;
          "${name}-headless" = mkHomeConfig (args // { headless = true; });
        }) hosts;

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
