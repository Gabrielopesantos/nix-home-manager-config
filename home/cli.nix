{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    fastfetch
    fd
    jq
    yq
    glow
    gnumake
    httpie
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
    lsof
    dnsutils
  ];
}
