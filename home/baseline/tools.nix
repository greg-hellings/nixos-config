{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      dig
      dnsutils
      jqp
      iamb
      rainfrog
      tenere
      wiki-tui
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      impala
    ]);

  programs = {
    zellij = {
      enable = true;
      attachExistingSession = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
      settings = {
        keybinds = {
          normal._children = [
            {
              bind = {
                _args = [ "Ctrl b" ];
                _children = [
                  {
                    SwitchToMode._args = [ "locked" ];
                  }
                ];
              };
            }
          ];
        }; # /keybinds
      }; # /settings
    };
  };
}
