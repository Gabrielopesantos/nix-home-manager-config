{ ... }: {
  imports = [
    ./core.nix
    ./home.nix
    ./fzf.nix
    ./gpg.nix
    ./git.nix
    ./tmux.nix
    ./devtools.nix
  ];
}
