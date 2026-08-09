{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dnsutils
    mosh
    mtr
    whois
    wireguard-tools
  ];
}
