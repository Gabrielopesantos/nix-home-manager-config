{ config, lib, pkgs, ... }:
with lib; {
  options = {
    devTools.enable = mkEnableOption "developer tools and applications" // {
      default = true;
    };
  };

  config = mkIf config.devTools.enable (let
    ccusage = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "ccusage";
      version = "18.0.10";
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
        hash = "sha256-YMJ8K2LmS0v0HeoRskfULZ7P7rVBpgYJRlDmZjndRiw=";
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
  in {
    home.packages = with pkgs; [
      # Go
      golangci-lint

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

      # GUI Tools
      sqlitebrowser
      wireshark

      # GTK Development
      icon-library

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
    programs.claude-code = {
      enable = true;
      agents = {
        code-reviewer = ''
          ---
          name: code-reviewer
          description: Specialized code review agent
          tools: Read, Edit, Grep
          ---

          You are a senior software engineer specializing in code reviews.
          Focus on code quality, security, and maintainability.
        '';
      };
      settings = {
        permissions.defaultMode = "acceptEdits";
        alwaysThinkingEnabled = true;
      };
      rules = {
        conventional-commits = ''
          When writing git commit messages, always follow the Conventional Commits specification:
          - Format: <type>[optional scope]: <description>
          - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
          - Example: feat(auth): add OAuth2 login support
          - Breaking changes: append `!` after the type or add `BREAKING CHANGE:` in the footer
          - Keep the subject line under 72 characters
          - Use imperative mood in the description ("add" not "added")
        '';
        rust-cli-tools = ''
          When using CLI tools, prefer Rust implementations over GNU/POSIX defaults:
          - `ls` -> `eza`
          - `cat` -> `bat`
          - `find` -> `fd`
          - `grep` -> `ripgrep` (`rg`)
          - `sed` / `awk` -> `sd`
          - `du` -> `dust`
          - `ps` -> `procs`
          - `top` / `htop` -> `btm` (bottom)
          - `curl` (for simple fetches) -> `xh`
          - `cut` -> `choose`
          Only fall back to GNU tools if the Rust alternative is not available or lacks a required feature.
        '';
      };
    };

    # Enable developer programs
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.jq.enable = true;
    programs.vscode.enable = true;
  });
}
