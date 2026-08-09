{
  # home.username / home.homeDirectory are set per host in ../hosts/<name>.nix
  home.stateVersion = "25.05";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.nix-profile/bin" # binaries for non-nixOS
  ];

  # Always restart/start/stop systemd services on home manager switch.
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
