{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    eternal-terminal
    k9s
    kubectl
    mosh
    mtr
    whois
    wireguard-tools
  ];

  home.sessionVariables = {
    BAO_ADDR = "http://127.0.0.1:8200";
  };
}
