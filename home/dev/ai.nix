{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  # Exposed as an option rather than a `let` binding so a host can contribute keys
  # (e.g. a work machine pointing Claude Code at Bedrock).
  #
  # types.attrsOf types.anything deep-merges attrsets but conflicts on lists rather
  # than concatenating them, which breaks the case that matters here: a host adding
  # hooks.SessionStart entries alongside the herdr one below. Hence the explicit
  # coercion to a merge-friendly list type for `hooks` (Claude Code runs every
  # matching entry, so concatenation is the correct semantic).
  # Scalars use mkDefault below so a host can override them outright.
  options.claudeCode.settings = mkOption {
    type = types.submodule {
      freeformType = types.attrsOf types.anything;
      options.hooks = mkOption {
        type = types.attrsOf (types.listOf types.anything);
        default = { };
        description = "Claude Code hook definitions, keyed by event name.";
      };
    };
    default = { };
    description = "Contents of ~/.claude/settings.json. Hosts may add or override keys.";
  };

  config = mkIf config.devTools.enable (
    let
      jsonFormat = pkgs.formats.json { };

      claudeSettingsFile = jsonFormat.generate "claude-code-settings.json" config.claudeCode.settings;

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
      claudeCode.settings = {
        alwaysThinkingEnabled = true;
        effortLevel = mkDefault "high";
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
        model = mkDefault "claude-sonnet-5[1m]";
        permissions = {
          allow = [
            "Read(${config.home.homeDirectory}/.claude/**)"
            "Read(${config.home.homeDirectory}/.agents/**)"
          ];
          defaultMode = mkDefault "plan";
        };
        statusLine = {
          type = "command";
          command = "bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
        };
        theme = "dark-ansi";
        tui = "fullscreen";
      };

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
        code-simplifier = "${claudeOfficialPlugins}/plugins/code-simplifier";
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

      # Copied from the store rather than symlinked out of it with
      # mkOutOfStoreSymlink. Claude Code only ever reads this script, so it does not
      # need to be writable, and the out-of-store form bound the build to a specific
      # clone path: the resulting store symlink is a build input, so activation broke
      # if the repo was not checked out at ~/nix-home-manager-config (dangling
      # symlink) or if $HOME was not traversable by the nixbld build users
      # (EACCES). Editing this script now needs a switch to take effect.
      home.file.".claude/statusline-command.sh" = {
        source = ../../claude/statusline-command.sh;
        executable = true;
      };
    }
  );
}
