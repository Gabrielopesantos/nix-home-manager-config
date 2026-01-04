{
  home = rec {
    stateVersion = "25.05";
    username = "gabriel";
    homeDirectory = "/home/${username}";
  };

  # Always restart/start/stop systemd services on home manager switch.
  systemd.user.startServices = "sd-switch";
}
