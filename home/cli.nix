{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    devenv
    dust
    fastfetch
    fd
    jq
    jless
    yq
    glow
    gnumake
    ncdu
    httpie
    jujutsu
    rclone
    ripgrep
    sd
    pass
    tldr
    tokei
    dust
    tree

    man-pages
    man-pages-posix
    file
    zip
    unzip
    lsof

    # Nix
    nh # home-manager/nixos-rebuild wrapper; shows a package diff before switching
    nix-diff # explains why two derivations differ, input by input
    nix-output-monitor # `nom build` - readable, structured build output
    nix-tree # interactive browser of a package's dependency closure
    nvd # diffs package versions between two generations
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "OneHalfDark";
    };
  };

  # comma (`, cowsay hi` - run a package once without installing it)
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
