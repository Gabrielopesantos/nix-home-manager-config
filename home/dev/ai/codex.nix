{
  config,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.devTools.enable (
    let
      plugins = import ./plugins.nix { inherit lib; };
    in
    {
      # No `skills`: Codex reads ~/.agents/skills (./default.nix).
      programs.codex = {
        enable = true;

        # Codex edits config.toml at runtime; merge declared keys into a writable file.
        mutableSettings = true;
        settings = {
          approval_policy = "on-request";
          # Needed by caveman's hooks.
          features.hooks = true;
          file_opener = "none";
          hide_agent_reasoning = false;
          model_reasoning_effort = "high";
          sandbox_mode = "workspace-write";
          sandbox_workspace_write.network_access = false;
          tui.status_line = [
            "model-with-reasoning"
            "git-branch"
            "context-used"
            "five-hour-limit"
          ];
        };

        context = ./AGENTS.md;
        enableMcpIntegration = true;

        hooks = "${plugins.caveman}/.codex/hooks.json";
      };
    }
  );
}
