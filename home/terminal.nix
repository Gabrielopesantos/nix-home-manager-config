{ config, pkgs, ... }:
let
  configFilePath = "${config.xdg.configHome}/tmux/tmux.conf";
in
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;

      experimental.pane_history = true;

      theme = {
        name = "one-dark";
        auto_switch = false;
      };

      ui = {
        agent_panel_sort = "spaces";
        toast.delivery = "herdr";
        sound.enabled = false;
      };

      terminal = {
        default_shell = "fish";
        # Replaces tmux's `-c "#{pane_current_path}"` split/new-window binds.
        new_cwd = "follow";
      };

      keys = {
        prefix = "ctrl+a";

        command = [
          {
            key = "prefix+alt+g";
            type = "popup";
            command = "lazygit";
            description = "run lazygit";
            width = "80%";
            height = "80%";
          }
        ];
      };
    };
  };

  programs.tmux = {
    enable = true;
    # Binds `C-a` to last-window
    shortcut = "a";
    # starts window numbers at 1 to match keyboard order with tmux window order
    baseIndex = 1;
    keyMode = "vi";
    clock24 = true;
    escapeTime = 50;
    historyLimit = 50000;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "xterm-256color";

    mouse = true;
    # Neovim says it needs this
    focusEvents = true;
    # vim-like pane switching (h/j/k/l) plus H/J/K/L pane resizing
    customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      yank

      # Session/pane persistence across reboots.
      resurrect
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }

      # prefix+F: fuzzy session/window/pane/clipboard/process switcher.
      tmux-fzf

      # prefix+]: fuzzy-pick word/line/path from pane scrollback, 'y' to copy.
      {
        plugin = extrakto;
        extraConfig = ''
          set -g @extrakto_key ']'
          set -g @extrakto_copy_key 'y'
        '';
      }
    ];

    extraConfig = ''
      # renumber windows sequentially after closing any of them
      set -g renumber-windows on

      # 'v'/'y' in copy-mode-vi are native/yank-provided (system clipboard).
      # Setup 'P' to paste selection
      bind P paste-buffer

      # Rebind spit and new-window commands to use current path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # vim-like last-window switching
      bind -r ^ last-window

      # Mousemode
      # Toggle mouse on
      bind m set -g mouse on \; display 'Mouse Mode: ON'

      # Toggle mouse off
      bind M set -g mouse off \; display 'Mouse Mode: OFF'

      # New window in background by middle click on status line
      bind-key -n MouseDown2Status new-window -ad -t= -c '#{pane_current_path}'

      # Reload tmux config
      bind-key R run-shell 'tmux source-file ${configFilePath} > /dev/null; \
                            tmux display-message "Sourced ${configFilePath}"'

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
  };
}
