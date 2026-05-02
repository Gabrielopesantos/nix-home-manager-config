{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (final: prev: {
            wireshark = prev.wireshark.overrideAttrs (old: {
              src = final.fetchzip {
                url = "https://gitlab.com/api/v4/projects/wireshark%2Fwireshark/repository/archive.tar.gz?sha=refs%2Ftags%2Fv4.6.5";
                hash = "sha256-Zvrwxjp4LK2J3QnxmPxKKrU01YHQvPyp54UWzeGNCjA=";
              };
            });
          })
        ];
      };
    in {
      homeConfigurations = {
        "gabriel" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./home ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { system = system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            black
            cargo
            git-crypt
            nixfmt
            pre-commit
          ];
        };
      }));
}
