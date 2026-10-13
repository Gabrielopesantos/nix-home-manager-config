{ lib, ... }:
with lib;
{
  imports = [
    ./languages.nix
    ./editors.nix
    ./ai
  ];

  options.devTools.enable = mkEnableOption "developer tools and applications" // {
    default = true;
  };
}
