{ pkgs, ... }:
{
  programs.bottom.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
  };

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
    settings = {
      # Search UI opens as a floating tmux popup instead of drawing over the
      # pane (falls back to normal rendering outside tmux).
      tmux.enabled = true;
      # Adds "workspace" (current git repo tree) to the ctrl-r filter modes
      # you can cycle through. Default search scope stays global.
      workspaces = true;
      # herdr's resume_agents_on_restore feature injects this command as
      # real keystrokes into panes on restore.
      history_filter = [ "^claude --resume" ];
    };
    daemon.enable = false;
  };

  programs.htop.enable = true;

  programs.lazygit = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
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
        # Prompt. Configured by the interactive `tide configure` wizard, which
        # writes fish universal variables.
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
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

      # Atuin's fish integration binds Up to the same interactive popup as
      # ctrl-r (search/filter-mode config only changes what's pre-filtered
      # inside it, doesn't skip it). Rebind Up back to fish's plain
      # walk-backward history so ctrl-r stays the only key that opens the
      # popup. Runs on fish_prompt (not here directly) since atuin's own
      # binding is sourced after interactiveShellInit and would win a
      # same-pass rebind here.
      function _restore_native_up_arrow --on-event fish_prompt
          bind up up-or-search
          bind \eOA up-or-search
          bind \e\[A up-or-search
          if bind -M insert >/dev/null 2>&1
              bind -M insert up up-or-search
              bind -M insert \eOA up-or-search
              bind -M insert \e\[A up-or-search
          end
      end
    '';
  };
}
