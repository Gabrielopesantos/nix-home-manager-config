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
      kubectl
      kubectx
      stern
    ];

    # Module (not just the package) so Stylix can write the k9s skin.
    programs.k9s.enable = true;
  };
}
