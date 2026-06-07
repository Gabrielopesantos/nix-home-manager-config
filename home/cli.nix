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
    pass
    tldr
    tokei
    tree
    nvd
    nix-diff
    file
    zip
    unzip
  ];

  programs.jq.enable = true;
}
