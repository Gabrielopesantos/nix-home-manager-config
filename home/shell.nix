{ lib, pkgs, ... }:
let
  # Starship's Nerd Font preset (glyphs instead of emoji), minus the parts set below.
  nerdFontSymbols =
    removeAttrs
      (builtins.fromTOML (
        builtins.readFile (
          pkgs.runCommand "starship-nerd-font.toml" { }
            "${pkgs.starship}/bin/starship preset nerd-font-symbols > $out"
        )
      ))
      [
        "$schema"
        "character"
        "git_status"
      ];
in
{
  programs.bottom.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza.enable = true;

  # Installs the fzf binary (which fzf-fish depends on) and FZF_DEFAULT_OPTS,
  # but leaves key bindings to fzf-fish - otherwise both bind ctrl-r and the
  # winner is decided by source order rather than by us.
  programs.fzf = {
    enable = true;
    enableFishIntegration = false;
    tmux.enableShellIntegration = true;
    # atuin owns ctrl-r for history search; drop fzf's nushell ctrl-r binding
    # so they don't fight over it.
    historyWidget.nushell.command = "";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    forceOverwriteSettings = true;
    # Keep native Up-arrow history in all shells; Ctrl-R opens Atuin.
    flags = [ "--disable-up-arrow" ];
    settings = {
      # Search UI opens as a floating tmux popup instead of drawing over the
      # pane (falls back to normal rendering outside tmux).
      tmux.enabled = true;
      # Adds "workspace" (current git repo tree) to the ctrl-r filter modes
      # you can cycle through. Default search scope stays global.
      workspaces = true;
    };
  };

  programs.htop.enable = true;

  programs.lazygit.enable = true;

  programs.nushell.enable = true;
  programs.nushell.loadSessionVariables = true;

  programs.zoxide.enable = true;

  # Same info as the old tide prompt. Left: path, git. Right: exit status, slow-command time, ssh/root user@host,
  # background jobs, direnv, nix shell, containers, cloud/k8s contexts and
  # language versions. Language modules only show inside a matching project.
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # Old prompts shrink to a bare `$` in the scrollback.
    enableTransience = true;
    settings = lib.recursiveUpdate nerdFontSymbols {
      add_newline = false;
      # The right-hand modules sit on the first line, pushed right by $fill.
      # fish puts `right_format` on the input line, so it is not used.
      format =
        "$directory$git_branch$git_commit$git_state$git_status$fill"
        + builtins.concatStringsSep "" (
          map (m: "$" + m) [
            "status"
            "cmd_duration"
            "username"
            "hostname"
            "jobs"
            "direnv"
            "bun"
            "nodejs"
            "python"
            "rust"
            "java"
            "php"
            "pulumi"
            "golang"
            "gcloud"
            "kubernetes"
            "container"
            "terraform"
            "aws"
            "nix_shell"
            "elixir"
            "zig"
            "time"
          ]
        )
        + "$line_break$character";
      fill.symbol = " ";

      # Parents shrink to one char (/h/g/w/project); the last dir stays whole.
      directory = {
        fish_style_pwd_dir_length = 1;
        truncation_length = 1;
        truncate_to_repo = false;
      };
      git_branch.format = "[$branch]($style) ";
      cmd_duration = {
        min_time = 3000;
        format = "[$duration]($style) ";
      };
      status.disabled = false;
      # Off by default in starship; tide showed all of these.
      direnv = {
        disabled = false;
        symbol = "direnv ";
        format = "[$symbol$loaded]($style) ";
      };
      nix_shell.format = "[$symbol$state]($style) ";
      # Only show the k8s context in directories that look like k8s projects.
      kubernetes = {
        disabled = false;
        detect_files = [
          "kustomization.yaml"
          "Chart.yaml"
          "skaffold.yaml"
        ];
        detect_folders = [
          "k8s"
          "kubernetes"
          "manifests"
        ];
      };
      time = {
        disabled = false;
        time_format = "%T";
      };
    };
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
      {
        name = "bang-bang";
        src = pkgs.fishPlugins.bang-bang.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "plugin-sudope";
        src = pkgs.fishPlugins.plugin-sudope.src;
      }
      {
        name = "fish-completion-sync";
        src = pkgs.fetchFromGitHub {
          owner = "pfgray";
          repo = "fish-completion-sync";
          rev = "f75ed04e98b3b39af1d3ce6256ca5232305565d8";
          sha256 = "sha256-wmtMUVi/NmbvJtrPbORPhAwXgnILvm4rjOtjl98GcWA=";
        };
      }
    ];

    shellAbbrs = {
      k = "kubectl";
      lg = "lazygit";
      vim = "nvim";
      wt = "git worktree";
      tf = "terraform";
    };

    shellAliases = {
      cat = "bat";
    };

    # -P-c passes -c to grotty, restoring overstrike output instead of SGR
    # escapes, which is what the colored-man-pages plugin's LESS_TERMCAP_*
    # colors act on. (GROFF_NO_SGR does not work: man-db overrides it.)
    shellInit = ''
      set -gx MANROFFOPT -P-c
    '';

    interactiveShellInit = ''
      set -g fish_color_option magenta

      # Ctrl+X,E to edit command line in editor (like zsh)
      bind \cx\ce edit_command_buffer

      # fzf-fish owns fzf bindings except ctrl-r, which atuin's fish
      # integration binds for history search (--history="" disables fzf-fish's
      # own ctrl-r binding so it doesn't just lose a race with atuin's).
      # --directory on ctrl-t keeps the key that fzf's own file widget used
      # before its integration was disabled.
      fzf_configure_bindings --directory=ctrl-t --history=""
    '';
  };
}
