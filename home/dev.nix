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
      ccusage =
        let
          nativePkg = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@ccusage/ccusage-linux-x64/-/ccusage-linux-x64-20.0.6.tgz";
            hash = "sha256-Wl94vPpOZ4A74sG3AFDz64grUmUxPTF/PIWze7yO/xw=";
          };
        in
        pkgs.stdenvNoCC.mkDerivation rec {
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
            mkdir -p $out/lib/ccusage/node_modules/@ccusage/ccusage-linux-x64 $out/bin
            cp -r . $out/lib/ccusage
            tar xf ${nativePkg} -C $out/lib/ccusage/node_modules/@ccusage/ccusage-linux-x64 --strip-components=1
            chmod +x $out/lib/ccusage/node_modules/@ccusage/ccusage-linux-x64/bin/ccusage
            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ccusage \
              --add-flags "$out/lib/ccusage/dist/cli.js"
          '';
        };
    in
    {
      home.packages = with pkgs; [
        # Editors
        neovim

        # Nix
        nixd
        nixfmt

        # Languages
        odin
        zig

        # Go
        golangci-lint

        # Rust
        cargo
        rustc

        # Python
        python3Packages.ptpython

        # Databases
        litecli
        pgcli
        postgresql

        # Utilities
        ccusage
        tree-sitter
        watchexec

        # Debugging
        ltrace
        valgrind

        # Docs / static sites
        hugo
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
      };

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
    }
  );
}
