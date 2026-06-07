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

  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = true;
  };

  programs.htop.enable = true;

  programs.lazygit = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 10;
    };
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
      {
        name = "bang-bang";
        src = pkgs.fishPlugins.bang-bang.src;
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

    shellAliases = {
      lg = "lazygit";
      vim = "nvim";
      k = "kubectl";
      cat = "bat";
    };

    interactiveShellInit = ''
      # Ctrl+X,E to edit command line in editor (like zsh)
      bind \cx\ce edit_command_buffer
    '';
  };
}
