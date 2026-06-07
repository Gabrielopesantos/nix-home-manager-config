{ config, pkgs, ... }:
let
  configFilePath = "${config.xdg.configHome}/tmux/tmux.conf";
in
{
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

    plugins = with pkgs.tmuxPlugins; [ yank ];

    extraConfig = ''
      # start pane indexing at 1 for tmuxinator
      set-window-option -g pane-base-index 1

      # renumber windows sequentially after closing any of them
      set -g renumber-windows on

      # Set mouse on
      set -gq mouse on

      # Neovim says it needs this
      set-option -g focus-events on

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

      # New window in background by middle click on status line
      bind-key -n MouseDown2Status new-window -ad -t= -c '#{pane_current_path}'

      # Reload tmux config
      bind-key R run-shell 'tmux source-file ${configFilePath} > /dev/null; \
                            tmux display-message "Sourced ${configFilePath}!"'

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
