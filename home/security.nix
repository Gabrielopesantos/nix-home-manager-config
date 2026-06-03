{ pkgs, ... }:
let
  agentTTL = 60 * 60 * 8; # 8 hours in seconds
in
{
  home.packages = with pkgs; [
    bitwarden-cli
    yubikey-manager
    yubikey-personalization
  ];

  home.sessionVariables = {
    KEYID = "67825262EAAF4EBE";
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    verbose = true;
    defaultCacheTtl = agentTTL;
    maxCacheTtl = agentTTL;
  };
}
