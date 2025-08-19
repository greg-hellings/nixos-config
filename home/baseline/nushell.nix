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

        def --env unlock [] {
          if "BW_SESSION" not-in $env {
            $env.BW_SESSION = ^bw unlock --raw
          }
        }

        def --env vpn [] {
          unlock
          let username = ^bw get username f7351f9c-b25b-4317-8352-affc00da4644
          let password = ^bw get password f7351f9c-b25b-4317-8352-affc00da4644
          let otp = ^bw get totp 10371487-7f40-4b08-9a45-b33e00de318b
          osascript ${vpn} $username $"($password)($otp)"
        }

        def rebuild [] {
          if (uname | get operating-system) == "Darwin" {
            sudo darwin-rebuild switch
          } else {
            let hostname = uname | get nodename
            let build = ^nom build $"/etc/nixos#nixosConfigurations.($hostname).config.system.build.toplevel" | complete
            if build.exit_code == 0 {
              nvd diff /run/current-system result
              sudo nixos-rebuild switch
            }
          }
        }

        def deploy [ $host: string, $build: string = "" ] {
          mut buildhost = $build
          if $build == "" {
            $buildhost = $host
          }
          if $buildhost == "linode" {
            $buildhost = "isaiah"
          }
          nixos-rebuild switch --use-remote-sudo --use-substitutes --target-host $host --build-host $buildhost
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
