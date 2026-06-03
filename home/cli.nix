{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    fastfetch
    fd
    glow
    gnumake
    httpie
    jq
    rclone
    ripgrep
    sd
    tldr
    tokei
    tree
  ];

  programs.jq.enable = true;
}
