{
  home = rec {
    stateVersion = "25.05";
    username = "gabriel";
    homeDirectory = "/home/${username}";
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
