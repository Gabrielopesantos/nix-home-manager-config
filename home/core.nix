{
  home = rec {
    stateVersion = "25.05";
    username = "gabriel";
    homeDirectory = "/home/${username}";
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.nix-profile/bin" # binaries for non-nixOS
  ];

  # Always restart/start/stop systemd services on home manager switch.
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
