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
      claudeCavemanPlugin = pkgs.fetchFromGitHub {
        name = "claude-plugin-caveman";
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "0d95a81d35a9f2d123a5e9430d1cfc43d55f1bb0";
        hash = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
      };

      claudeKarpathyPlugin = pkgs.fetchFromGitHub {
        name = "claude-plugin-andrej-karpathy-skills";
        owner = "forrestchang";
        repo = "andrej-karpathy-skills";
        rev = "2c606141936f1eeef17fa3043a72095b4765b9c2";
        hash = "sha256-4z/wRdYH7UXRzF8RJU0sw8xbpx0BW/7CBv5sVEC2knY=";
      };

      claudeMattPocockPlugin = pkgs.fetchFromGitHub {
        name = "claude-plugin-mattpocock-skills";
        owner = "mattpocock";
        repo = "skills";
        rev = "9603c1cc8118d08bc1b3bf34cf714f62178dea3b";
        hash = "sha256-S6pARK99oGGSi6XdFm6zYKHT4gjOCN0wIPZFcl1hREE=";
      };

      claudeOfficialPlugins = pkgs.fetchFromGitHub {
        name = "claude-plugin-official";
        owner = "anthropics";
        repo = "claude-plugins-official";
        rev = "e09c3b1e5f6e8edbe2cdaf55b5dc38cf87824389";
        hash = "sha256-etAd44W11CfOzAR3B+NihqUIdPCGI8Eypw2jPiHCkhw=";
      };

      # Symlinked per-skill-directory (not as one ".claude/skills" symlink) so these can
      # coexist with programs.claude-code.plugins, which manages its own
      # ".claude/skills/<plugin-name>" entries under the same parent directory.
      vendoredSkillNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../claude/skills)
      );
    in
    {
      home.packages = (
        with pkgs;
        [
          # Editors
          neovim

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
          postgresql

          # Utilities
          tree-sitter
          watchexec

          # Debugging
          ltrace
          valgrind

          # Docs / static sites
          hugo

          # Usage tracking
          ccusage

          # OpenCode
          opencode
          opencode-desktop
        ]
      );

      home.sessionVariables = {
        EDITOR = "nvim";
      };

      programs.claude-code.enable = true;

      # Loaded via --plugin-dir, not the marketplace/install registry, so Claude Code never
      # needs to write to ~/.claude/plugins/*.json for these to work — no clobbering on switch.
      # Attrset form (not a bare list) so directory names under ~/.claude/skills stay fixed
      # instead of tracking each source's store-path hash, which changes on every pin bump.
      programs.claude-code.plugins = {
        claude-plugin-caveman = claudeCavemanPlugin;
        claude-plugin-andrej-karpathy-skills = claudeKarpathyPlugin;
        claude-plugin-mattpocock-skills = claudeMattPocockPlugin;
        code-review = "${claudeOfficialPlugins}/plugins/code-review";
        skill-creator = "${claudeOfficialPlugins}/plugins/skill-creator";
      };

      # Use mkOutOfStoreSymlink so Claude Code can write to settings.json at runtime.
      # The Nix store is read-only, so a normal home.file symlink would cause EACCES.
      home.file = lib.mkMerge [
        {
          ".claude/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-home-manager-config/claude/settings.json";

          ".claude/statusline-command.sh".source =
            config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-home-manager-config/claude/statusline-command.sh";
        }
        (lib.listToAttrs (
          map (
            name:
            lib.nameValuePair ".claude/skills/${name}" {
              source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-home-manager-config/claude/skills/${name}";
            }
          ) vendoredSkillNames
        ))
      ];
    }
  );
}
