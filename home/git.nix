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
        # status / diff
        st = "status";
        s = "status --short --branch";
        d = "diff";
        dc = "diff --cached";
        dw = "diff --word-diff";

        # staging
        a = "add";
        aa = "add --all";
        ap = "add --patch";
        au = "add --update";

        # commit
        c = "commit --verbose";
        cm = "commit --message";
        ca = "commit --all --verbose";
        cam = "commit --all --message";
        cne = "commit --amend --no-edit";

        # checkout / switch
        co = "checkout";
        cb = "checkout -b";
        sw = "switch";
        swc = "switch --create";

        # branch
        br = "branch";
        bra = "branch --all";
        brd = "branch --delete";

        # log
        lo = "log --oneline --decorate";
        lol = "log --oneline --graph --decorate";
        loa = "log --oneline --graph --decorate --all";
        ls = "log --stat";

        # fetch / pull / push
        f = "fetch";
        fa = "fetch --all --prune";
        pl = "pull";
        p = "push";
        pf = "push --force-with-lease";

        # rebase
        rb = "rebase";
        rbi = "rebase --interactive";
        rbc = "rebase --continue";
        rba = "rebase --abort";
        rbs = "rebase --skip";

        # reset / restore
        undo = "reset HEAD~1 --mixed";
        unstage = "restore --staged";
        rh = "reset --hard";

        # stash
        sta = "stash push";
        stp = "stash pop";
        stl = "stash list";
        stu = "stash push --include-untracked";

        # cherry-pick
        cp = "cherry-pick";
        cpa = "cherry-pick --abort";
        cpc = "cherry-pick --continue";

        # misc
        m = "merge";
        ma = "merge --abort";
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
