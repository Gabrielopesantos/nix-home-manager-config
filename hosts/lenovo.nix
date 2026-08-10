{ lib, pkgs, ... }:
{
  # Employer-specific values (cluster paths, Bedrock credentials for Claude Code) live
  # outside this public repo, in ~/.config/home-manager-local/lenovo.nix.
  #
  # The path is absolute and outside the flake tree on purpose. A gitignored file
  # *inside* the tree does not work: flakes copy only git-tracked files into the store,
  # so `builtins.pathExists ./local.nix` evaluates against the store copy and is always
  # false -- even under --impure. Requires --impure for getEnv (the Makefile passes it).
  #
  # Optional, so the host still evaluates on a machine that has no such file.
  imports =
    let
      home = builtins.getEnv "HOME";
      localConfig = "${home}/.config/home-manager-local/lenovo.nix";
    in
    lib.optional (home != "" && builtins.pathExists localConfig) localConfig;

  home = rec {
    username = "gsantos";
    homeDirectory = "/home/${username}";
    # Deliberately behind ../home/core.nix's default: raising this opts into state
    # migrations for files already on this machine. Bump as its own change.
    stateVersion = "24.05";
  };

  gui.enable = true;
  # Work laptop: desktop infrastructure (ghostty, pinentry-qt) but none of the
  # personal apps from ../home/gui.nix.
  personalApps.enable = false;

  home.packages = with pkgs; [
    # Infrastructure
    terraform
    pulumi
    granted
    k3d
    headlamp
    jsonnet
    sem
    skopeo

    # Languages / build
    php
    clang
    vcpkg

    # Utilities
    jwt-cli

    # 1Password
    _1password-gui
    _1password-cli
    drawy
  ];

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.krew/bin"
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    PIP_REQUIRE_VIRTUALENV = "true";
  };

  # Sole version manager on this host: pyenv and nvm were retired in favour of mise,
  # which works natively in fish. idiomatic_version_file_enable_tools is what makes
  # mise read the .python-version files the work projects already pin with.
  programs.mise = {
    enable = true;
    globalConfig = {
      tools = {
        node = "lts";
      };
      settings = {
        idiomatic_version_file_enable_tools = [ "python" ];
      };
    };
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    plugins = {
      mappings = {
        K = "preview-tui";
      };
      src = pkgs.nnn + "/plugins";
    };
  };
}
