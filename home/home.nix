{
  pkgs,
  lib,
  host ? "most",
  top,
  username,
  ...
}:
let
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${username}"
    else if username == "root" then
      "/root"
    else
      "/home/${username}";
in
{
  imports = [
    top.nixvimunstable.homeManagerModules.nixvim
    top.self.modules.homeManagerModule
    ./baseline
  ] ++ lib.optionals (builtins.pathExists ./hosts/${host}) [ ./hosts/${host} ];

  home = {
    inherit homeDirectory username;

    packages = with pkgs; [
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
    stateVersion = "25.05";
  };

  programs = {
    broot = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
    };
    keychain = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
      keys = [
        "id_rsa"
        "id_ed25519"
        "personal_ed25519"
      ];
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "xterm-256color";
      customPaneNavigationAndResize = true;
      extraConfig = (lib.strings.concatStringsSep "\n" [ "bind P paste-buffer" ]);
    };
    yazi = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
    };
  };
}
