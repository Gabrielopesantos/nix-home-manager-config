# Global instructions

- The machine is managed with Nix and home-manager. Do not install tools globally
  with pip, npm -g, cargo install or curl scripts. Use a missing tool once with
  `nix run nixpkgs#<pkg> -- <args>` or `nix shell nixpkgs#<pkg>`.
- Prefer a project's own dev shell (`nix develop`, `flake.nix`, `shell.nix`) when
  one exists.
- Prefer ASD-STE100 Simplified Technical English (STE). Use ASCII art to explain
  flows and diagrams whenever possible.
