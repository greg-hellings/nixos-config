{
  config,
  lib,
  pkgs,
  ...
}:
let
  vpn = pkgs.writeText "vpn" ''
    on run argv
      ignoring application responses
        tell application "Viscosity"
          connect "350Main"
        end tell
      end ignoring

      delay 1.0

      activate application "Viscosity"
      tell application "System Events" to keystroke item 1 of argv
      delay 0.1
      tell application "System Events" to keystroke tab
      delay 0.1
      tell application "System Events" to keystroke item 2 of argv
      delay 0.1
      tell application "System Events" to keystroke return
    end run
  '';
in
{
  programs = {
    nushell = {
      enable = true;
      environmentVariables = config.home.sessionVariables;
      extraConfig = ''
        use std/util "path add"
        path add ${config.home.homeDirectory}/src/bin
        path add /opt/homebrew/bin
        path add /run/current-system/sw/bin
        path add ${config.home.homeDirectory}/.nix-profile/bin

        source ${./nushell/functions.nu}

        def --env vpn [] {
          unlock
          let login = ^bw get item f7351f9c-b25b-4317-8352-affc00da4644 | from json
          let otp = ^bw get totp 10371487-7f40-4b08-9a45-b33e00de318b
          osascript ${vpn} $login.login.username $"($login.login.password)($otp)"
        }

        # From the nushell cookbook: https://www.nushell.sh/cookbook/ssh_agent.html#keychain
        do --env {
            let ssh_agent_file = (
                $nu.temp-path | path join $"ssh-agent-(whoami).nuon"
            )

            if ($ssh_agent_file | path exists) {
                let ssh_agent_env = open ($ssh_agent_file)
                if (ps | find --columns [pid] $ssh_agent_env.SSH_AGENT_PID | is-not-empty) {
                    load-env $ssh_agent_env
                    print $"Agent found, and loading ($ssh_agent_env)"
                    print $env.SSH_AUTH_SOCK
                    return
                } else {
                    print "Agent not found, removing file and starting again"
                    rm $ssh_agent_file
                }
            }

            let ssh_agent_env = ^ssh-agent -c
                | lines
                | first 2
                | parse "setenv {name} {value};"
                | transpose --header-row
                | into record
            print $"Starting agent ($ssh_agent_env)"
            load-env $ssh_agent_env
            $ssh_agent_env | save --force $ssh_agent_file
        }
      '';
      settings = {
        buffer_editor = lib.getExe config.programs.nixvim.package;
        "history.isolation" = true;
        "history.file_format" = "sqlite";
      };
    };
  };
  home.shell.enableNushellIntegration = true;
}
