# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

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
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      edk2-uefi-shell.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    create_ssl
    step-ca
  ];

  networking.hostName = "genesis"; # Define your hostname.
}
