{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.cloud.enable = mkEnableOption "cloud and cluster tools" // {
    default = true;
  };

  config = mkIf config.cloud.enable {
    home.packages = with pkgs; [
      awscli2
      k9s
      kubectl
      kubectx
      stern
    ];
  };
}
