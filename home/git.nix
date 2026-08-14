{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    git-get
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;

    signing = {
      key = "67825262EAAF4EBE";
      signByDefault = true;
      format = "openpgp";
    };

    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"

      # Editors
      ".idea/"
      ".vscode/"
      "*.swp"
      "*.swo"
      "*~"

      # Nix
      ".direnv/"

      # Secrets / env
      ".env"
      ".env.local"

      # Claude
      "**/.claude/settings.local.json"
    ];

    settings = {
      user = {
        name = "Gabriel Santos";
        email = "me@gabrielopesantos.com";
      };

      init.defaultBranch = "main";
      rebase.autoSquash = true;
      status.submoduleSummary = true;
      core.editor = "nvim";
      color.ui = true;
      merge.conflictStyle = "zdiff3";
      pull.rebase = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      rerere.enabled = true; # remember merge resolutions
      commit.verbose = true;

      alias = {
        br = "branch";
        undo = "reset HEAD~1 --mixed";
        stu = "stash push --include-untracked";
        cl = "clone --recurse-submodules";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "base16-256";
    };
  };
}
