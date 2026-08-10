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
        xournalpp
        gromit-mpx
        obsidian
        yubioath-flutter
        sqlitebrowser
        wireshark
        icon-library
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
          nextcloud-client
          bitwarden-desktop
        ]
      );

    services.tailscale-systray = {
      enable = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "Noto Sans Mono";
        font-size = 12;

        window-theme = "dark";
        background-blur = true;

        cursor-style = "block";
        mouse-hide-while-typing = true;
        command = "${pkgs.fish}/bin/fish --login";
        shell-integration = "fish";
      };
    };
  };
}
