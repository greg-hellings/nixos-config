# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  speedtest_port = "19472";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
  ];

  greg = {
    home = true;
    gnome.enable = false;
    proxies = {
    };
  };

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    useOSProber = true;
  };

  environment.systemPackages = with pkgs; [
    create_ssl
    step-ca
  ];

  networking.hostName = "genesis"; # Define your hostname.

  virtualisation.oci-containers.containers = {
  };
}
