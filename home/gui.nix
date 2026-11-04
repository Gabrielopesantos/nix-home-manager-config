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
      gromit-mpx
      protonmail-desktop
      proton-vpn
      obsidian
      discord
      vlc
      yubioath-flutter
      sqlitebrowser
      wireshark
      signal-desktop
      telegram-desktop
      nextcloud-client
      bitwarden-desktop
      kooha
      grok-bot
    ];

    # Module (not just the package) so Stylix can write the zathura colors.
    programs.zathura.enable = true;

    services.tailscale-systray = {
      enable = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        background-blur-radius = 20;

        mouse-hide-while-typing = true;
        command = "${pkgs.fish}/bin/fish --login";
      };
    };
  };
}
