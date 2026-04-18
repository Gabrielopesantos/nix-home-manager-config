{ config, pkgs, ... }: {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    fastfetch
    tokei # Does the same as cloc, just giving trying it ougcc
    valgrind
    fd
    rclone
    jq
    ripgrep
    bat
    sd
    tree
    gnumake
    awscli2
    httpie
    kubectl
    k9s
    tldr
    obsidian
    # Networking tools
    mtr
    wireguard-tools
    whois

    glow
    hugo

    brave
    zathura
    bitwarden-desktop
    protonmail-desktop
    proton-vpn
    httpie-desktop

    yubikey-manager
    yubioath-flutter
    yubikey-personalization
    bitwarden-cli

    nixfmt
    nixd

    zig
    odin

    discord
    audacious
    audacity
    vlc
    asdf-vm

    # anki

    # system call monitoring
    ltrace # library call monitoring
    # strace # system call monitoring
    # lsof # list open files

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "LiberationMono" ]; }) // NOTE: This doesn't work this anymore

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.bottom.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    # icons = false;
  };

  programs.neovim = { enable = true; };

  programs.zsh = {
    enable = false;
    autosuggestion.enable = true;
    enableCompletion = true;

    initContent = ''
      #   eval "$(lua /path/to/z.lua --init zsh)"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" ];
      theme = "gallois";
    };

    shellAliases = {
      lg = "lazygit";
      vim = "nvim";
      k = "kubectl";
      cat = "bat";
    };

    syntaxHighlighting = { enable = true; };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --color-only --dark --paging=never";
          useConfig = false;
        };
      };
    };
  };

  programs.nushell = {
    enable = true;
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "067e867debee59aee231e789fc4631f80fa5788e";
          sha256 = "sha256-emmjTsqt8bdI5qpx1bAzhVACkg0MNB/uffaRjjeuFxU=";
        };
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
      {
        name = "plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "d6950214b6b2392d3dbb2cb670f2a5f240090038";
          sha256 = "sha256-0uEKw+7EXkf5u3p3hfthSfQO/2rr3wl35ela7P2vB0Q=";
        };
      }
      {
        name = "plugin-bang-bang";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-bang-bang";
          rev = "ec991b80ba7d4dda7a962167b036efc5c2d79419";
          sha256 = "sha256-oPPCtFN2DPuM//c48SXb4TrFRjJtccg0YPXcAo0Lxq0=";
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

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 10; # Increase timeout

      # character = {
      #   success_symbol = "λ";
      #   error_symbol = "!";
      # };
      # format = "$character";
      # right_format = "$direnv$nix_shell$directory";
      #
      # # Optimize directory module
      # directory = {
      #   style = "purple";
      #   truncation_length = 3; # Limit directory depth
      #   truncate_to_repo = true; # Stop at git repo root
      #   read_only = " 🔒";
      # };
      #
      # # Optimize direnv
      # direnv = {
      #   disabled = false;
      #   format = "[$allowed]($style)";
      #   style = "red";
      #   allowed_msg = "";
      #   not_allowed_msg = "? ";
      #   denied_msg = " ";
      # };
      #
      # # Optimize nix_shell
      # nix_shell = {
      #   format = "[$symbol]($style)";
      #   symbol = " ";
      # };
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/gabriel/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    KEYID = "67825262EAAF4EBE";
    NIXPKGS_ALLOW_UNFREE = "1";
    BAO_ADDR = "http://127.0.0.1:8200";
  };

  # services.pcscd.enable = true;
  # services.scdaemon.enable = true;

  home.sessionPath = [
    "$HOME/.asdf/shims"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.nix-profile/bin" # binaries for non-nixOS
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.htop.enable = true;
}
