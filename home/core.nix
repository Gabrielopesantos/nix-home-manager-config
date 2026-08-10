{ lib, ... }:
{
  # home.username / home.homeDirectory are set per host in ../hosts/<name>.nix.
  # mkDefault so a host can pin an older stateVersion: raising it opts into state
  # migrations for files already on disk, which is a per-machine decision.
  home.stateVersion = lib.mkDefault "25.05";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.nix-profile/bin" # binaries for non-nixOS
  ];

  # Always restart/start/stop systemd services on home manager switch.
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
