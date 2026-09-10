# Bootstrap

Steps to set up on a fresh machine.

## Hosts

One flake output per machine, defined in `hosts/` and wired up in `flake.nix`:

| Output            | Host file           | User      |
| ----------------- | ------------------- | --------- |
| `gabriel`         | `hosts/casper.nix`  | `gabriel` |
| `gsantos@lenovo`  | `hosts/lenovo.nix`  | `gsantos` |

Shared configuration lives in `home/`; each host file sets its identity, its
`stateVersion`, and any host-only packages or feature flags (`gui.enable`,
`personalApps.enable`, `devTools.enable`, `cloud.enable`).

Every output also has a `<output>-headless` companion that forces `gui.enable`
off, for machines reached over SSH. It is a separate output because module
options cannot be overridden from the `home-manager` command line.

## 1. Install Nix (non-NixOS only)

Determinate Systems installer - enables flakes by default:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart shell or source the Nix profile after install.

## 2. Clone config

```sh
git clone <repo-url> ~/nix-home-manager-config
```

Any path works. `~/.config/home-manager` lets `home-manager switch` run without
`--flake`, at the cost of being a less obvious place to find the repo.

## 3. First switch

`home-manager` is not yet on `PATH` on a fresh machine, so run it via `nix run`:

```sh
cd ~/nix-home-manager-config
nix run home-manager -- switch --impure --flake .#gabriel        # or .#gsantos@lenovo
```

`--impure` is required: `hosts/lenovo.nix` reads `$HOME` to locate its private
overrides (step 6).

Subsequent switches:

```sh
make update                      # defaults to HOST=gabriel
make update HOST=gsantos@lenovo
make headless HOST=...           # switches .#$HOST-headless, no GUI packages
```

If activation refuses to overwrite unmanaged files it found in `$HOME`, re-run
with `-b <ext>` to move them aside instead of failing:

```sh
nix run home-manager -- switch -b premerge --impure --flake .#<host>
```

## 4. Configure the fish prompt

tide stores its configuration in fish universal variables, so it cannot be managed
declaratively. Run the wizard once per machine:

```sh
tide configure
```

## 5. Set fish as default shell (non-NixOS only)

Home Manager installs fish but can't write `/etc/shells` on non-NixOS:

```sh
echo $HOME/.nix-profile/bin/fish | sudo tee -a /etc/shells
chsh -s $HOME/.nix-profile/bin/fish
```

Log out and back in for the change to take effect.

## 6. Private per-host overrides

Values that should not be in this public repo (work cluster paths, work email
addresses, alternate Claude Code providers) go in a file outside the repo:

```
~/.config/home-manager-local/<host>.nix
```

`hosts/lenovo.nix` imports it if it exists. It is a normal home-manager module, so
it can set any option, including adding to `claudeCode.settings`:

```nix
{
  home.sessionVariables.KUBECONFIG = "/home/you/.kube/some.config";
  claudeCode.settings.model = "us.anthropic.claude-opus-5[1m]";

  # `../home/git.nix` sets the personal address with `lib.mkDefault`, so a plain
  # assignment here wins. Without this line the host commits as the personal
  # identity. The signing key stays shared -- add the work address as a UID on
  # the key (`gpg --edit-key $KEYID`, `adduid`) or those commits show as
  # Unverified on GitHub.
  programs.git.settings.user.email = "you@company.example";
}
```

The path is deliberately outside the flake. A gitignored file *inside* the tree
does not work: flakes copy only git-tracked files into the store, so
`builtins.pathExists ./local.nix` is false at evaluation time even under
`--impure`. This file is not version-controlled anywhere -- back it up privately,
since a fresh machine needs it recreated by hand.

## 7. Language toolchains

`mise` manages per-project language versions and reads `.python-version` files
(`idiomatic_version_file_enable_tools`). After the first switch:

```sh
mise install
```

## NixOS

On NixOS, home-manager can be used standalone (same steps above) or as a NixOS module. With standalone, fish shell path registration is handled automatically via `programs.fish.enable`.
