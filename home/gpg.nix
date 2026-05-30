{ pkgs, ... }:
let
  agentTTL = 60 * 60 * 8; # 8 hours in seconds
in
{
  programs.gpg.enable = true;

  # M ake the gpg-agent work
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    verbose = true;

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = agentTTL;
    maxCacheTtl = agentTTL;
  };
}
