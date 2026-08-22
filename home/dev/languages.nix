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
      # Go
      go
      golangci-lint

      # Rust
      rustc
      cargo

      # Node (floats on nixos-unstable)
      nodejs_latest

      # Python
      python3
      python3Packages.ptpython

      # Zig
      zig

      # Nix
      nixd
      nixfmt

      # Databases
      litecli
      pgcli

      # Utilities
      tree-sitter
      watchexec
      gcc

      # Debugging
      ltrace
      valgrind
    ];
  };
}
