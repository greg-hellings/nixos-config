{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      dig
      dnsutils
      jqp
      kubernetes-helm
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
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
      settings = {
        default_shell = "xonsh";
        plugins = {
          autolock = {
            _props.location = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
            _children = [
              {
                is_enabled = true;
              }
              {
                triggers = "nvim|vim|git";
              }
              {
                reaction_seconds = "0.3";
              }
              {
                print_to_log = true;
              }
            ];
          };
        };
        load_plugins.autolock = { };
        keybinds = {
          normal._children = [
            {
              bind = {
                _args = [ "Enter" ];
                _children = [
                  {
                    WriteChars = "\\u{000D}";
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [ { } ];
                    };
                  }
                ];
              };
            }
            {
              bind = {
                _args = [ "Ctrl z" ];
                _children = [
                  {
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [
                        {
                          payload._args = [ "enable" ];
                        }
                      ];
                    };
                    SwitchToMode._args = [ "Locked" ];
                  }
                ];
              };
            }
          ]; # /normal
          locked._children = [
            {
              bind = {
                _args = [ "Ctrl z" ];
                _children = [
                  {
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [
                        {
                          payload._args = [ "disable" ];
                        }
                      ];
                    };
                    SwitchToMode._args = [ "Normal" ];
                  }
                ];
              };
            }
          ]; # /locked
          shared_except = {
            _args = [ "locked" ];
            _children = [
              {
                bind = {
                  _args = [ "Ctrl h" ];
                  MoveFocusOrTab._args = [ "Left" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl j" ];
                  MoveFocus._args = [ "Down" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl k" ];
                  MoveFocus._args = [ "Up" ];
                };
              }
              {
                bind = {
                  _args = [ "Ctrl l" ];
                  MoveFocusOrTab._args = [ "Right" ];
                };
              }
            ];
          }; # /shared_except
        }; # /keybinds
      }; # /settings
    };
  };
}
