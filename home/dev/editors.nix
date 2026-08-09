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
        helix
      ])
      ++ optional config.gui.enable pkgs.zed-editor;

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.vscode.enable = config.gui.enable;
  };
}
