{
  programs.home-manager.enable = true;

  home = rec {
    stateVersion = "25.05";
    username = "gabriel";
    homeDirectory = "/home/${username}";
  };

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
}