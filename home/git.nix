{ pkgs, ... }: {
  home.packages = with pkgs; [ gh git-get ];
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;

    signing = {
      key = "67825262EAAF4EBE";
      signByDefault = false;
      format = "openpgp";
    };

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
      delta.navigate = true;
      delta.dark = true;
      delta.side-by-side = true;
      delta.line-numbers = true;
      delta.syntax-theme = "base16-256";
      merge.conflictStyle = "zdiff3";
      # commit.gpgsign = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Shell aliases for git...
}
