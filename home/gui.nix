{ config, lib, pkgs, ... }:
with lib; {
  options.gui.enable = mkEnableOption "GUI applications" // { default = true; };

  config = mkIf config.gui.enable {
    home.packages = with pkgs; [
      brave
      zathura
      kdePackages.okular
      xournalpp
      sioyek
      gromit-mpx
      bitwarden-desktop
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
    ];

    programs.vscode.enable = true;
  };
}
