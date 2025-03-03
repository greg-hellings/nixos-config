{
  pkgs,
  config,
  lib,
  top,
  ...
}:

let
  cfg = config.greg.vscodium;
in
{
  options.greg.vscodium = lib.mkEnableOption "Enable installation of VSCodium on the host";

  config = lib.mkIf cfg {
    home.packages = with pkgs; [
      buildifier
      gopls
      nixd # nix language server
    ];

    # An alternative editor to vim, when I need it for some things
    programs.vscode = {
      enable = true;
      #package = pkgs.vscodium;
      profiles.default = {
        extensions =
          with top.vsext.extensions."${pkgs.stdenv.system}".vscode-marketplace;
          [
            arrterian.nix-env-selector
            asvetliakov.vscode-neovim
            batisteo.vscode-django
            donjayamanne.python-environment-manager
            golang.go
            kevinrose.vsc-python-indent
            jnoortheen.nix-ide
            mkhl.direnv
            ms-python.python
            njpwerner.autodocstring
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
            vadimcn.vscode-lldb
            vscjava.vscode-java-test
            vscjava.vscode-java-dependency
            vscjava.vscode-java-debug
            wholroyd.jinja
          ]
          ++ (with top.vsext.extensions."${pkgs.stdenv.system}".vscode-marketplace-release; [
            github.copilot
            github.copilot-chat
          ]);
        userSettings = {
          "direnv.restart.automatic" = true;
          "direnv.path.executable" = (lib.getExe pkgs.direnv);
          "extensions.autoUpdate" = false;
          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
          "git.openRepositoryInParentFolders" = "always";
          "search.exclude" = {
            "**/.tox" = true;
          };
          "terminal.integrated.defaultProfile.linux" = "tmux";
          "vscode-neovim.neovimInitVimPaths.darwin" = "~/.config/nvim/init.lua";
          "vscode-neovim.neovimInitVimPaths.linux" = "~/.config/nvim/init.lua";
          "workbench.settings.applyToAllProfiles" = [ "direnv.path.executable" ];
        };
      };
    };
  };
}
