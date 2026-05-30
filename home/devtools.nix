{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    devTools.enable = mkEnableOption "developer tools and applications" // {
      default = true;
    };
  };

  config = mkIf config.devTools.enable (
    let
      ccusage = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "ccusage";
        version = "20.0.6";
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
          hash = "sha256-hXKQF7jUVz71/BKn++V7S+OC9uCuc0+6TYYZ5MKjGcM=";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        unpackPhase = "tar xf $src";
        sourceRoot = "package";
        installPhase = ''
          mkdir -p $out/lib/ccusage $out/bin
          cp -r . $out/lib/ccusage
          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ccusage \
            --add-flags "$out/lib/ccusage/dist/index.js"
        '';
      };
    in
    {
      home.packages = with pkgs; [
        # Go
        golangci-lint

        # Rust
        cargo
        rustc

        # Shell Utilities
        eternal-terminal
        mosh
        tree-sitter
        watchexec

        # SQL Terminal GUI
        postgresql
        litecli
        pgcli

        # Better Python REPL
        python3Packages.ptpython

        # Claude Code Usage Analysis
        ccusage
      ];

      # Go
      programs.go = {
        enable = true;
        package = pkgs.go_1_26;
        telemetry.mode = "off";
      };

      # Claude
      programs.claude-code.enable = true;

      # Use mkOutOfStoreSymlink so Claude Code can write to settings.json at runtime.
      # The Nix store is read-only, so a normal home.file symlink would cause EACCES.
      home.file.".claude/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/claude/settings.json";
      };

      home.file.".claude/statusline-command.sh".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/claude/statusline-command.sh";

      home.file.".claude/rules/conventional-commits.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/claude/rules/conventional-commits.md";
      };

      # Enable developer programs
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.jq.enable = true;
    }
  );
}
