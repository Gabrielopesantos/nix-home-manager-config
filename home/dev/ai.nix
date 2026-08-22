{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.devTools.enable (
    let
      jsonFormat = pkgs.formats.json { };

      claudeSettings = {
        alwaysThinkingEnabled = true;
        effortLevel = "high";
        hooks.SessionStart = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "bash '${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];
        mcpServers = { };
        model = "claude-sonnet-5[1m]";
        permissions = {
          allow = [
            "Read(${config.home.homeDirectory}/.claude/**)"
            "Read(${config.home.homeDirectory}/.agents/**)"
          ];
          defaultMode = "plan";
        };
        statusLine = {
          type = "command";
          command = "bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
        };
        theme = "dark-ansi";
        tui = "fullscreen";
      };

      claudeSettingsFile = jsonFormat.generate "claude-code-settings.json" claudeSettings;

      # Plugin sources are pinned via npins (../../npins), not fetchFromGitHub, so
      # `npins update` can bump all of them in one lockfile diff without
      # declaring each repo as a flake input. Run `npins add ...` to add a new
      # one; see ../../npins/sources.json for current pins.
      pluginSources = import ../../npins;

      claudeCavemanPlugin = pluginSources.claude-plugin-caveman;
      claudeKarpathyPlugin = pluginSources.claude-plugin-karpathy-skills;
      claudeMattPocockPlugin = pluginSources.claude-plugin-mattpocock-skills;
      claudeOfficialPlugins = pluginSources.claude-plugins-official;
    in
    {
      home.packages = with pkgs; [
        opencode

        # Usage tracking
        ccusage
      ];

      programs.claude-code.enable = true;

      # Loaded via --plugin-dir, not the marketplace/install registry, so Claude Code never
      # needs to write to ~/.claude/plugins/*.json for these to work - no clobbering on switch.
      # Attrset form (not a bare list) so directory names under ~/.claude/skills stay fixed
      # instead of tracking each source's store-path hash, which changes on every pin bump.
      programs.claude-code.plugins = {
        claude-plugin-caveman = claudeCavemanPlugin;
        claude-plugin-andrej-karpathy-skills = claudeKarpathyPlugin;
        claude-plugin-mattpocock-skills = claudeMattPocockPlugin;
        code-review = "${claudeOfficialPlugins}/plugins/code-review";
        skill-creator = "${claudeOfficialPlugins}/plugins/skill-creator";
      };

      # settings.json is installed as a plain writable file via home.activation
      # below, since the Nix store is read-only and Claude Code needs to write
      # to settings.json at runtime (plugin toggles, /effort, hooks).
      # Each `home-manager switch` reinstalls the declared content fresh,
      # overwriting whatever Claude wrote in between.
      home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -Dm644 ${claudeSettingsFile} "${config.home.homeDirectory}/.claude/settings.json"
      '';

      # The agent-state hook scripts are owned by herdr ("managed by herdr;
      # reinstalling or updating the integration overwrites this file"), so they
      # are installed by herdr's own installer rather than vendored here. This
      # config only declares the reference to the Claude hook above. Without this
      # step a fresh host gets a settings.json pointing at a script that does not
      # exist.
      home.activation.herdrIntegrations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${pkgs.herdr}/bin/herdr integration install claude || true
        $DRY_RUN_CMD ${pkgs.herdr}/bin/herdr integration install opencode || true
      '';

      home.file.".claude/statusline-command.sh".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-home-manager-config/claude/statusline-command.sh";
    }
  );
}
