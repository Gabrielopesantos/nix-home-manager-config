{ lib, pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";

    fonts.monospace = {
      package = pkgs.nerd-fonts.noto;
      name = "Noto Sans Mono";
    };
    fonts.sizes.terminal = 13;
    opacity.terminal = 0.95;

    # Stylix's rofi module still sets the renamed `programs.rofi.font`,
    # which prints an eval warning. rofi is not used here.
    targets.rofi.enable = false;

    # Hyprland is not used; its Stylix target triggers a configType warning.
    targets.hyprland.enable = false;

    # KDE and GTK are managed by NixOS, not by this home-manager config.
    targets.gtk.enable = false;
    targets.kde.enable = false;
  };

  # ~/.local/state/nix/profiles/home-manager/specialisation/light/activate
  specialisation.light.configuration.stylix = {
    polarity = lib.mkForce "light";
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tomorrow.yaml";
  };
}
