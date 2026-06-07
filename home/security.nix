{ pkgs, config, ... }:
let
  agentTTL = 60 * 60 * 8; # 8 hours in seconds
  pinentryPkg = if config.gui.enable then pkgs.pinentry-qt else pkgs.pinentry-tty;
in
{
  home.packages = with pkgs; [
    bitwarden-cli
    yubikey-manager
    yubikey-personalization
    pinentryPkg
    pcsc-tools # for pcsc_scan
    cryptsetup
  ];

  home.sessionVariables = {
    KEYID = "67825262EAAF4EBE";
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ../keys/gabriel-pub.asc;
        trust = "ultimate"; # your own key -> ultimate, so encrypt-to-self is promptless
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true; # THIS is what makes the A subkey act as your SSH agent
    pinentry.package = pinentryPkg;
    verbose = true;
    defaultCacheTtl = agentTTL;
    maxCacheTtl = agentTTL;
  };
}
