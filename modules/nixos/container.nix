{
  config,
  lib,
  top,
  overlays,
  ...
}:

let
  cfg = config.greg.containers;

  # Create a container with all our default settings

  makeContainer =
    _: container:
    let
      agekey = "/etc/ssh/agenix_key";
    in
    {
      autoStart = true;
      timeoutStartSec = "20min";
      hostAddress = "192.168.${container.subnet}.1";
      localAddress = "192.168.${container.subnet}.2";
      privateNetwork = true;
      bindMounts = {
        "${agekey}".hostPath = "/etc/ssh/ssh_host_ed25519_key"; # This is needed for agenix to
      };
      enableTun = container.tailscale;
      config =
        { ... }:
        {
          imports = [
            top.agenix.nixosModules.default
            top.self.modules.nixosModule
            container.builder
          ];

          _module.args.self = null; # Prevents containers from getting builder access
          nixpkgs.overlays = overlays;

          networking = {
            firewall.enable = true;
            useHostResolvConf = lib.mkForce false;
          };

          age.identityPaths = [ agekey ];

          greg.tailscale.enable = container.tailscale;
        };
    };
in
{
  options.greg.containers = lib.mkOption {
    default = { };

    type =
      with lib.types;
      attrsOf (submodule ({
        options = {
          tailscale = lib.mkOption {
            type = bool;
            default = false;
            description = "Enable tailscale in the container";
          };
          subnet = lib.mkOption {
            type = str;
            default = "200";
          };
          builder = lib.mkOption {
            default = { ... }: { };
            description = ''
              This needs to be a function, like the one for
              a container's config. It will setup the core system above the
              defaults set in this module.
            '';
            example = ''
              { pkgs, config, lib, ... } :
              {
              	services.openssh.enable = true;
              }
            '';
          };
        };
      }));
  };

  config = {
    containers = builtins.mapAttrs makeContainer cfg;
  };
}
