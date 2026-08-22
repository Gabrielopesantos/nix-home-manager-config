{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.devTools.enable {
    home.packages =
      (with pkgs; [
        neovim
      ])
      ++ optional config.gui.enable pkgs.zed-editor;

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
