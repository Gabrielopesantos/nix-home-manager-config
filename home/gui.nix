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

  # Split out so a work machine can have the desktop infrastructure below
  # (terminal, pinentry-qt via ../home/security.nix) without the personal apps.
  options.personalApps.enable = mkEnableOption "personal (non-work) desktop applications" // {
    default = true;
  };

  config = mkIf config.gui.enable {
    home.packages =
      (with pkgs; [
        # wl-copy/wl-paste - system clipboard target for tmux's yank and
        # extrakto plugins (both auto-detect it on Wayland).
        wl-clipboard

        zathura
        gromit-mpx
        obsidian
        yubioath-flutter
        sqlitebrowser
        wireshark
        kooha
      ])
      ++ optionals config.personalApps.enable (
        with pkgs;
        [
          brave
          protonmail-desktop
          proton-vpn
          discord
          vlc
          signal-desktop
          telegram-desktop
          nextcloud-client
          bitwarden-desktop
          grok-bot
        ]
      );

    # Module (not just the package) so Stylix can write the zathura colors.
    programs.zathura.enable = true;

    services.tailscale-systray = {
      enable = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        background-blur-radius = 20;
        cursor-style = "block";

        mouse-hide-while-typing = true;
        command = "${pkgs.fish}/bin/fish --login";
        shell-integration = "fish";
      };
    };
  };
}
