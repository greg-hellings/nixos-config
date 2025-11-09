{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        ups = "push -u origin HEAD";
        amend = "commit --amend";
      };
      branch.sort = "-committerdate";
      column.ui = "auto";
      commit.verbose = "true";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = "true";
        renames = "true";
      };
      init.defaultBranch = "main";
      push.default = "upstream";
      pull.rebase = "false";
      rebase = {
        autoSquash = "true";
        updateRefs = "true";
      };
      rerere = {
        autoupdate = "true";
        enabled = "true";
      };
      tag.sort = "version:refname";
      user = {
        name = "Greg Hellings";
        email = "greg.hellings@gmail.com";
      };
    };
    ignores = [
      ".*.swp"
      ".*.swo"
      ".*.swn" # vim
      ".idea" # IntelliJ
      ".DS_Store" # Macs
      "Thumbs.db" # Windows
      ".tox" # Tox temp directory
      ".eclipse" # These next two are created by VSCodium plugins
      ".bazelproject"
    ];
  };
}
