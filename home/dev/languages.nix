{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.devTools.enable {
    home.packages = with pkgs; [
      # Rust
      rustc
      cargo

      # Node (floats on nixos-unstable)
      nodejs_latest

      # Python
      python3
      python3Packages.ptpython

      # Nix
      nixd
      nixfmt

      # Databases
      litecli
      pgcli

      # Utilities
      watchexec
      gcc

      # Debugging
      ltrace
      valgrind
    ];
  };
}
