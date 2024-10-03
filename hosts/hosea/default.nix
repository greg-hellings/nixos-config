# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, ... }:
let
  wanInterface = "enp2s0";
  lanInterface = "enp1s0";
  lanIpAddress = "10.42.1.7";
in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.btc.nixosModules.default
      ./bitcoin.nix
    ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/";
      };
    };
    extraModprobeConfig = "vboxdrv";
  };
  users.users.greg.extraGroups = [ "vboxusers" ];

  networking = {
    hostName = "hosea";
    nameservers = [ "10.42.1.5" ];
    defaultGateway = "10.42.1.1";
    interfaces = {
      "${wanInterface}".useDHCP = true;
      "${lanInterface}" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = lanIpAddress;
          prefixLength = 16;
        }];
      };
    };
  };

  # Serves as the router, DHCP, and DNS for the site
  greg = {
    tailscale.enable = true;
    home = true;
  };
  services = {
    # Configure keymap
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
