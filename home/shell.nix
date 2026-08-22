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
