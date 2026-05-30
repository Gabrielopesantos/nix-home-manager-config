# Bootstrap

Steps to set up on a fresh machine.

## 1. Install Nix (non-NixOS only)

Determinate Systems installer - enables flakes by default:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart shell or source the Nix profile after install.

## 2. Clone config

```sh
git clone <repo-url> ~/.config/home-manager
```

## 3. First switch

```sh
cd ~/.config/home-manager
nix run home-manager -- switch --impure --flake .#gabriel
```

Subsequent switches: `make update`
Headless machines (no GUI): `make headless`

## 4. Set fish as default shell (non-NixOS only)

Home Manager installs fish but can't write `/etc/shells` on non-NixOS:

```sh
echo $HOME/.nix-profile/bin/fish | sudo tee -a /etc/shells
chsh -s $HOME/.nix-profile/bin/fish
```

Log out and back in for the change to take effect.

## NixOS

On NixOS, home-manager can be used standalone (same steps above) or as a NixOS module. With standalone, fish shell path registration is handled automatically via `programs.fish.enable`.
