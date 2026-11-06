{
  config,
  lib,
  pkgs,
  ...
}:
let
  defaultPrompt = ''
    create a new herdr tab in the background. populate it with 4 panes in a 2 by 2 grid. In each pane start a new instance of claude code.
    1. the first pane should be prompted to serve as a code reviewer for the work we will be doing.
    2. the second pane will serve as a researcher. other agents should ask that agent questions that need research external to this repository. it should research questions on websites, api documentation, and so forth.
    3. the third pane should serve as an expert on this repository, planning and executing the work needed.
    4. the fourth should be opened in the context of the parent directory to this. it should serve as an expert on the scope of the whole enterprise. other agents should ask it questions about where this work fits into
       the whole enterprise, about other services and libraries which support this project, etc. start this agent with permissions only to execute the following commands: `gawk`, `herdr`, `ls`, `rg`, and `grep`.

    these agents should communicate directly with one another using the herdr functionality. those agents are to be as autonomous as possible, running without the expectation of direct human interaction.
    when they absolutely need human interaction they should ask you to coordinate with me.

    you will serve as the lead agent. human interaction should be routed through you. i will provide you inputs, and you will drive the other agents by communicating with them and delegating your work to them.
  '';
  claudeSwarm = (pkgs.writeShellApplication {
    name = "cswarm";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.ripgrep
    ];
    text = ''
      # shellcheck disable=SC2016
      claude '${defaultPrompt}'
    '';
  });
in
{
  home.packages =
    with pkgs;
    [
      claudeSwarm
      dig
      jqp
      kubernetes-helm
      #iamb
      lazyssh
      rainfrog
      ripgrep
      tenere
      uv
      wiki-tui
    ]
    ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      impala
    ]);

  programs = {
    herdr = {
      enable = true;
      settings = {
        keys = {
          # Panel navigation
          focus_pane_down = "ctrl+j";
          focus_pane_left = "ctrl+h";
          focus_pane_right = "ctrl+l";
          focus_pane_up = "ctrl+k";
          # Tab navigation
          next_tab = "ctrl+shift+l";
          previous_tab = "ctrl+shift+h";
        };
        onboarding = false;
        terminal = {
          default_shell = lib.getExe config.programs.nushell.package;
          new_cwd = "follow";
          shell_mode = "auto";
        };
        theme = {
          name = "dracula";
          auto_switch = false;
        };
        ui = {
          sound.enabled = false;
          toast.delivery = "system";
        };
      };
    };
    zellij = {
      enable = true;
      enableZshIntegration = pkgs.stdenv.hostPlatform.isDarwin;
      settings = {
        #default_shell = "xonsh";
        default_shell = lib.getExe config.programs.nushell.package;
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
          ]; # /normal
          locked._children = [
            {
              unbind = {
                _args = [ "Ctrl g" ];
              };
            }
          ];
          shared._children = [
            {
              bind = {
                _args = [ "Ctrl z" ];
                _children = [
                  {
                    MessagePlugin = {
                      _args = [ "autolock" ];
                      _children = [
                        {
                          payload._args = [ "toggle" ];
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
