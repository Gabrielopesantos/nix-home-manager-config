{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gabriel";
  # ??
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  # ??
  home.homeDirectory = "/home/gabriel";
  # This worked better (https://www.reddit.com/r/NixOS/comments/zyv0lu/comment/j6cxjbr)
  # https://github.com/nix-community/home-manager/issues/1439#issuecomment-1106208294
  # home.activation = {
  #   linkDesktopApplications = {
  #     after = [ "writeBoundary" "createXdgUserDirectories" ];
  #     before = [ ];
  #     data = ''
  #       rm -rf ${config.xdg.dataHome}/"applications/home-manager"
  #       mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
  #       cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
  #     '';
  #   };
  # };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neofetch
    nnn

    fd
    jq
    ripgrep
    tree

    httpie
    awscli2
    gh
    kubectl
    k9s
    tldr

    # Networking tools
    mtr

    glow
    hugo

    brave
    zathura
    bitwarden-desktop
    protonmail-desktop
    protonvpn-gui

    nixfmt-classic
    # pcsctools

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
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

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

  programs.go = {
    enable = true;
    # goPath = "Development/language/go";
  };

  programs.bottom.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    icons = false;
  };

  programs.neovim = { enable = true; };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    initExtra = ''
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

  # NOTE: Might override existing installation
  # programs.gpg.enable = true;

  programs.git = {
    enable = true;
    userName = "Gabriel Santos";
    userEmail = "me@gabrielopesantos.com";
    signing = {
      key = "67825262EAAF4EBE";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      color.ui = true;
      commit.gpgsign = true;
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    # shortcut = "a";  # Binds `C-a` to last-window
    # secureSocket = false;
    # NOTE: Review
    extraConfig = ''
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      bind r source-file ~/.tmux.conf
      # start window numbers at 1 to match keyboard order with tmux window order
      set -g base-index 1

      # start pane indexing at 1 for tmuxinator
      set-window-option -g pane-base-index 1

      # renumber windows sequentially after closing any of them
      set -g renumber-windows on

      # Faster escape sequences (default is 500ms).
      # This helps when exiting insert mode in Vim: http://superuser.com/a/252717/65504
      set -s escape-time 50

      # Set mouse on
      set -g mouse on

      # Neovim says it needs this
      set-option -g focus-events on

      # Use vim keybindings in copy mode
      setw -g mode-keys vi
      # Setup 'v' to begin selection
      bind-key -T copy-mode-vi v send -X begin-selection
      # Setup 'y' to copy selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel
      # Setup 'P' to paste selection
      bind P paste-buffer

      # Rebind spit and new-window commands to use current path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      set-window-option -g mode-keys vi # What does this do?
      #bind -T copy-mode-vi v send-keys -X begin-selection

      # vim-like pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Bind C-s to fuzzy switch session
      #bind -n C-s \
        #split-window -l 10 'session=$(tmux list-sessions -F "#{session_name}" | fzf --query="$2" --select-1 --exit-0) && tmux switch-client -t "$session"' \;

      # Mousemode
      # Toggle mouse on
      bind m set -g mouse on \; display 'Mouse Mode: ON'

      # Toggle mouse off
      bind M set -g mouse off \; display 'Mouse Mode: OFF'

      # Reload tmux config
      bind-key r source-file ~/.tmux.conf \; display-message "~/.tmux.conf reloaded"
      # Edit tmux conf
      #bind-key M split-window -h "vim ~/.tmux.conf"

      # Open a "test" split-window at the bottom
      bind t split-window -f -l 15 -c "#{pane_current_path}"
      # Open a "test" split-window at the right
      bind T split-window -h -f -p 35 -c "#{pane_current_path}"

      # Style status bar
      set -g status-style fg=grey
      set -g pane-active-border-style fg=green
      set -g window-status-format " #I:#W#F "
      set -g window-status-current-style fg=green
      set -g window-status-current-format " #I:#W#F "
      set -g window-status-activity-style bg=green,fg=yellow
      # set -g window-status-separator "|"
      set -g status-justify left

      # Automatically rename window to pane_current_path
      set-option -g status-interval 5
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'
    '';
    shell = "${pkgs.zsh}/bin/zsh";
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
  home.sessionVariables = { EDITOR = "nvim"; };

  # services.pcscd.enable = true;
  # services.scdaemon.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  # home.sessionPath = [
  #   "$HOME/.local/bin"
  #   "$HOME/bin"
  #   "$HOME/.nix-profile/bin" #binaries for non-nixOS
  # ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
