{ config, lib, pkgs, ... }:
with lib; {
  options = {
    devTools.enable = mkEnableOption "developer tools and applications" // {
      default = true;
    };
  };

  config = mkIf config.devTools.enable {
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
    ];

    # Go
    programs.go = {
      enable = true;
      package = pkgs.go_1_24;
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
    };

    # Enable developer programs
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.jq.enable = true;
    programs.vscode.enable = true;
  };
}
