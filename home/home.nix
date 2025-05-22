{
  pkgs,
  lib,
  host ? "most",
  top,
  ...
}:

{
  imports = [
    top.nixvimunstable.homeManagerModules.nixvim
    ./modules
  ] ++ lib.optionals (builtins.pathExists ./hosts/${host}) [ ./hosts/${host} ];

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "xterm-256color";
    customPaneNavigationAndResize = true;
    extraConfig = (lib.strings.concatStringsSep "\n" [ "bind P paste-buffer" ]);
  };

  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    copier
    diffutils
    findutils
    gh
    git
    gnupatch
    hms
    btop
    inetutils
    jq
    nano
    nix-prefetch
    nmap
    openssl
    setup-ssh
    tmux
    tree
    unzip
    wget
    zip
  ];
}
