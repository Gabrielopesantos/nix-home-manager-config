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
      brave
      zathura
      kdePackages.okular
      xournalpp
      gromit-mpx
      protonmail-desktop
      proton-vpn
      httpie-desktop
      obsidian
      discord
      audacious
      audacity
      vlc
      yubioath-flutter
      sqlitebrowser
      wireshark
      icon-library
      signal-desktop
      zed-editor
      nextcloud-client
      bitwarden-desktop
    ];

    programs.vscode.enable = true;

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;

        background-opacity = 0.95;
        background-blur-radius = 20;

        mouse-hide-while-typing = true;
        command = "bash -l -c nu";
      };
    };
  };
}
