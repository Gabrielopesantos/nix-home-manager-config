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
      plugins = import ./plugins.nix { inherit lib; };

      settings = {
        alwaysThinkingEnabled = true;
        effortLevel = "high";
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

      settingsFile = jsonFormat.generate "claude-code-settings.json" settings;

      # Plugin with `skills` flattened to skills/<name>, loaded by default discovery.
      mkSkillPlugin =
        {
          name,
          manifest,
          skills,
        }:
        pkgs.runCommand name { } ''
          mkdir -p $out/.claude-plugin $out/skills
          cp ${manifest} $out/.claude-plugin/plugin.json
          ${concatStrings (mapAttrsToList (skill: path: "cp -r ${path} $out/skills/${skill}\n") skills)}
        '';

      # Upstream lists nested skill paths in plugin.json; Claude Code rejects them
      # as escaping the plugin dir once home-manager symlinks them. Flatten instead.
      mattPocockFlat = mkSkillPlugin {
        name = "claude-plugin-mattpocock-skills";
        manifest = pkgs.runCommand "mattpocock-plugin.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
          jq 'del(.skills)' ${plugins.mattPocock}/.claude-plugin/plugin.json > $out
        '';
        skills = plugins.mattPocockSkills;
      };

      # Own skills + manifest-less upstream skills. A plugin, not
      # programs.claude-code.skills: OpenCode also reads ~/.claude/skills/*/SKILL.md.
      localSkills = mkSkillPlugin {
        name = "claude-plugin-local-skills";
        manifest = jsonFormat.generate "local-skills-plugin.json" { name = "local"; };
        skills = plugins.ownSkills // {
          session-report = "${plugins.official}/plugins/session-report/skills/session-report";
        };
      };
    in
    {
      programs.claude-code.enable = true;

      # ~/.claude/CLAUDE.md
      programs.claude-code.context = ./AGENTS.md;

      programs.claude-code.enableMcpIntegration = true;

      # From the official *-lsp marketplace entries; those plugin dirs have no manifest.
      programs.claude-code.lspServers = {
        rust-analyzer = {
          command = "rust-analyzer";
          extensionToLanguage.".rs" = "rust";
        };
        pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
          extensionToLanguage = {
            ".py" = "python";
            ".pyi" = "python";
          };
        };
        typescript = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
          extensionToLanguage = {
            ".ts" = "typescript";
            ".tsx" = "typescriptreact";
            ".js" = "javascript";
            ".jsx" = "javascriptreact";
            ".mts" = "typescript";
            ".cts" = "typescript";
            ".mjs" = "javascript";
            ".cjs" = "javascript";
          };
        };
      };

      home.packages = with pkgs; [
        rust-analyzer
        pyright
        typescript-language-server
      ];

      # Personal plugins in ~/.claude/skills/<name>, outside the marketplace registry.
      # Attrset keeps directory names stable across pin bumps.
      programs.claude-code.plugins = {
        claude-plugin-caveman = plugins.caveman;
        claude-plugin-andrej-karpathy-skills = plugins.karpathy;
        claude-plugin-mattpocock-skills = mattPocockFlat;
        claude-plugin-local-skills = localSkills;
        claude-md-management = "${plugins.official}/plugins/claude-md-management";
        code-review = "${plugins.official}/plugins/code-review";
        commit-commands = "${plugins.official}/plugins/commit-commands";
        pr-review-toolkit = "${plugins.official}/plugins/pr-review-toolkit";
        skill-creator = "${plugins.official}/plugins/skill-creator";
        security-guidance = "${plugins.official}/plugins/security-guidance";
      };

      # Writable copy: Claude Code edits settings.json at runtime. Each switch resets it.
      home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -Dm644 ${settingsFile} "${config.home.homeDirectory}/.claude/settings.json"
      '';

      home.file.".claude/statusline-command.sh".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-home-manager-config/claude/statusline-command.sh";
    }
  );
}
