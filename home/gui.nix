{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.gui.enable = mkEnableOption "GUI applications" // {
    default = true;
  };

  config = mkIf config.gui.enable {
    home.packages = with pkgs; [
      # wl-copy/wl-paste - system clipboard target for tmux's yank and
      # extrakto plugins (both auto-detect it on Wayland).
      wl-clipboard

      brave
      zathura
      xournalpp
      gromit-mpx
      protonmail-desktop
      proton-vpn
      obsidian
      discord
      vlc
      yubioath-flutter
      sqlitebrowser
      wireshark
      icon-library
      signal-desktop
      nextcloud-client
      bitwarden-desktop
      kooha
    ];

    services.tailscale-systray = {
      enable = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "Noto Sans Mono";
        font-size = 12;

        background-opacity = 0.95;
        background-blur-radius = 20;

        mouse-hide-while-typing = true;
        command = "${pkgs.fish}/bin/fish --login";
      };
    };
  };
}
