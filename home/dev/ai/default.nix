{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./claude.nix
    ./codex.nix
  ];

  config = mkIf config.devTools.enable {
    # Read by Codex and OpenCode. Claude Code gets plugins instead (./claude.nix).
    home.file =
      mapAttrs' (name: path: nameValuePair ".agents/skills/${name}" { source = path; })
        (import ./plugins.nix { inherit lib; }).sharedSkills;

    # Claude Code and Codex get AGENTS.md via `context`; OpenCode is a plain package.
    xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

    # Shared by modules with enableMcpIntegration.
    programs.mcp = {
      enable = true;
      servers.context7.url = "https://mcp.context7.com/mcp";
    };

    home.packages = with pkgs; [
      opencode
      code-cursor

      # Usage tracking
      ccusage
    ];
  };
}
